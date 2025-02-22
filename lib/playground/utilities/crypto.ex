defmodule Playground.Utilities.Crypto do
  @moduledoc """
  Funciones relacionadas a procesos criptográficos
  """
  @message_encryptor_salt "97ed1161-a5ad-493e-9d2b-7bfdc80a25cc"
  @message_encryptor_secret "876af3f8-5188-4b32-aecc-2abf7ebf03ab"

  def generate_rsa_key_pair() do
    private_key_file_path = "./private.pem"

    {private_key, 0} = System.cmd("openssl", ["genrsa", "2048"])
    File.write!(private_key_file_path, private_key)
    {public_key, 0} = System.cmd("openssl", ["rsa", "-pubout", "-in", private_key_file_path])

    # Se guarda en base64 para desencriptar la informacion del emisor
    private_key_base64 = Base.encode64(private_key)

    # Se comparte al emisor en base64
    public_key_base64 = Base.encode64(public_key)

    {private_key_base64, public_key_base64}
  end

  @doc """
  # Encriptar uno o varios datos usando AES GCM
  Ejemplo con un solo dato:
  - {:ok, mapped_data} = encrypt_specific_aes_gcm_data(public_key).(data_to_encrypt, data_name)

  Ejemplo con varios datos:
  - try_encrypt = encrypt_specific_aes_gcm_data(public_key)
  - {:ok, mapped_data1} = try_encrypt.(data_to_encrypt, data_name)
  - {:ok, mapped_dataX} = try_encrypt.(data_to_encrypt, data_name)
  - Al final los mapas resultantes se pueden fusionar con Map.merge() para devolver un solo mapa con todos los datos encriptados junto con un solo IV y AES
  """
  def encrypt_specific_aes_gcm_data(public_key) do
    key = public_key
    try_encrypt = aes_gcm_encrypt()

    fn (data_to_encrypt, data_name) ->
      case try_encrypt.(data_to_encrypt, key) do
        {:ok, {encrypted_data, iv, aes}} ->
          mapped_data = %{
            data_name => encrypted_data,
            "iv" => iv,
            "aes" => aes,
            "mode" => "GCM"
          }
          {:ok, mapped_data}

        error ->
          error
      end
    end
  end

  @doc """
  # Desencriptar uno o varios datos usando AES GCM
  Ejemplo con un solo dato:
  - {:ok, decrypted} = decrypt_specific_aes_gcm_data(mapped_data, private_key).(data_name)

  Ejemplo con varios datos:
  - try_decrypt = decrypt_specific_aes_gcm_data(mapped_data, private_key)
  - {:ok, decrypted1} = try_decrypt.(data_name)
  - {:ok, decryptedX} = try_decrypt.(data_name)
  - Los datos desencriptados se pueden utilizar directamente o ponerlos en otro tipo de dato segun se necesite
  """
  def decrypt_specific_aes_gcm_data(mapped_data, private_key) do
    map = mapped_data
    key = private_key

    fn data_name ->
      data = map[data_name]
      iv = map["iv"]
      aes = map["aes"]
      aes_gcm_decrypt(key, iv, aes, data)
    end
  end

  def aes_gcm_decrypt_webhook(aes_key_base64, encrypted_data_base64) do
    try do
      cipher = :aes_gcm
      gcm_iv_length = 12
      gcm_tag_length = 16

      aes_key = Base.decode64!(aes_key_base64)
      encrypted_data = Base.decode64!(encrypted_data_base64)
      iv = binary_slice(encrypted_data, 0..(gcm_iv_length - 1))
      ciphertext = binary_slice(encrypted_data, gcm_iv_length..(byte_size(encrypted_data) - (gcm_tag_length + 1)))
      aad = <<>>
      tag = binary_slice(encrypted_data, byte_size(encrypted_data) - gcm_tag_length..byte_size(encrypted_data))

      try_decrypt = :crypto.crypto_one_time_aead(cipher, aes_key, iv, ciphertext, aad, tag, false)

      case try_decrypt do
        :error ->
          {:error, "Decrypt error"}

        decrypted ->
          case Jason.decode(decrypted) do
            {:ok, map} -> {:ok, map}
            _ -> {:error, "JSON decode error"}
          end
      end
    rescue
      _ ->
        {:error, "Decrypt error exception"}
    end
  end

  def validate_rsa_public_key(public_key_base64) do
    try do
      public_key_pem = Base.decode64!(public_key_base64)

      public_key_decoded = public_key_pem
      |> :public_key.pem_decode()
      |> hd()
      |> :public_key.pem_entry_decode()

      {:RSAPublicKey, modulus, _} = public_key_decoded

      case byte_size(:binary.encode_unsigned(modulus)) do
        bytes when bytes in [256, 512] -> :ok
        _ -> {:error, "Invalid public key"}
      end
    rescue
      _ -> {:error, "RSA key error exception"}
    end
  end

  def message_encryptor_encrypt(data, secret \\ @message_encryptor_secret, salt \\ @message_encryptor_salt) do
    {secret_key, signing_key} = message_encryptor_generate_keys(secret, salt)
    Plug.Crypto.MessageEncryptor.encrypt(data, secret_key, signing_key)
  end

  def message_encryptor_decrypt(encrypted_data, secret \\ @message_encryptor_secret, salt \\ @message_encryptor_salt) do
    {secret_key, signing_key} = message_encryptor_generate_keys(secret, salt)
    case Plug.Crypto.MessageEncryptor.decrypt(encrypted_data, secret_key, signing_key) do
      {:ok, decrypted} ->
        {:ok, decrypted}

      _ ->
        {:error, "Decrypt error"}
    end
  end

  # Playground.Utilities.Crypto.test_decrypt_webhook()
  def test_decrypt_webhook() do
    Debug.print(self(), label: "Desencriptar JSON de la respuesta Webhook")

    aes_key_base64 = "QzVs1723SdnT60hnMtwy4d3HzXIruXUZ+i4WEj/pMFs="
    encrypted_message_base64 = "s8FKKuNyUCalvk5hp+MptRUwFvy+4HFWDyu9CvjyZ4zxOt8vLu6Ex+pLuozQYeYY3otqIjGrJ/PqsZGAqsI2iQVq4nrbUdS4SZydVnFKT/WIJ7uOOPVPq9qES0CHjvXxRbmQWnrC2nMgx/OdG2IvOSwU6UiOtuRycfzCvYqRCR2W3v/cmoagipn+gwtXWweENe9v+03UnliIPi7Cn+tFIwnmw9NPQxO3Z2n6k9r2T5F6nErpfNVQGSzJJ5kaV99xlODpMXimKpfBwayctgl229YB09QzrG4lUcPB06SnMLatU5BlVLa5tTX2ViNrRLz7nFT+usQNR2UDloLEjiY4e+LW0QG6pOA6/uv+alIz1Jt7qRchhcbfn4OXWKYbHitVIbEzlZN4vn8rx5n6pey5BfBKQr8fPCVVVq5Z82ATi/iwoFEZ7v2oy1u5dhdB19nNOEw1Wqhb+n+YduTWPJ6RSqQ1sIPhynPvAkLfVwebUoV47Ri0kb3+ZJMcXJ7q6/Y3s2uTLAR7J6h9yfpkdF9aUk7P8fgGGzIeOltEgAAW3lxmtq6ND3SQ9aHjYwjqq6/GsvOyRP9wHJ7HQy2NRz5FnhwQcJjhjf0PpFX6l+EQwi+lm6aUihjn0IMdffvl46eRRH5O2wwg74OQrYsQstVnjKTNqceppwWsnl8nGynh3NtvalcMzGWF6oTsc6z/GI0ZPngsAbx8/gT/TZKJKymHDF/8QgUhBubEHp7cLyBjpZZgjsN/RzQGnfltVTwWVp4Y1wa2kQZxidTil/6GbeSLNSk5Y6w9ImcH1WuXUptKdu9q1HZGyzwt7X5/z3fD9Wp96S0Q7iB5qXDXwpXvAVcp9wIcvKkgC7yq2W36FrvWoCCyGEQ1l9BEDmGC4iguEMyST7+kaP33hfNpGZo/WiW9EarJr1jmV8Ba+gRCIKN9nJNiL4oNHf4VTxT2Sx3pKD2hJ4CDMd/XRtlQXOTa1nR6958L9xIaK1KMio6j9HpoPKNiqp/lDCIxvBGiTaf8BI2g/eoGH1FrU/uViSYfsrwblIZhDf1cKAfkd3PR9Uiw/BmzcAv0mXH4Ujl/jzE3cPJQ9J/NquIvmalmPVsZ45cdt7wJy4HHfG+o/61IvpPxsaqHt1JrFCpiJw9Sx8A5Ea6NWDlnMUiac5w8CzK4CAr1Q7Nsc6cV8UeH"

    aes_gcm_decrypt_webhook(aes_key_base64, encrypted_message_base64)
  end

  defp message_encryptor_generate_keys(secret, salt) do
    secret_key = Plug.Crypto.KeyGenerator.generate(secret, salt, length: 32)
    signing_key = Plug.Crypto.KeyGenerator.generate(secret, salt <> "_signing", length: 32)

    {secret_key, signing_key}
  end

  defp aes_gcm_encrypt() do
    # Setup inicial
    cipher = :aes_gcm
    key_size = 32
    iv_size = 12
    aes = key_size |> :crypto.strong_rand_bytes()
    iv = iv_size |> :crypto.strong_rand_bytes()

    # Funcion de encriptado
    fn (data_to_encrypt, public_key_base64) ->
      try do
        public_key = Base.decode64!(public_key_base64)
        |> :public_key.pem_decode()
        |> hd()
        |> :public_key.pem_entry_decode()

        aad = <<>>

        iv_base64 = Base.encode64(iv)

        options = rsa_padding_opts()
        encrypted_aes_key_base64 = :public_key.encrypt_public(aes, public_key, options)
        |> Base.encode64()

        {encrypted_data, tag} = :crypto.crypto_one_time_aead(cipher, aes, iv, data_to_encrypt, aad, true)
        encrypted_data_base64 = Base.encode64(encrypted_data <> tag)

        {:ok, {encrypted_data_base64, iv_base64, encrypted_aes_key_base64}}
      rescue
        _ -> {:error, "Encrypt error exception"}
      end
    end
  end

  defp aes_gcm_decrypt(private_key_base64, iv_base64, aes_key_base64, encrypted_data_base64) do
    try do
      cipher = :aes_gcm
      gcm_tag_length = 16

      iv = Base.decode64!(iv_base64)
      aes = Base.decode64!(aes_key_base64)
      encrypted_data = Base.decode64!(encrypted_data_base64)

      private_key = Base.decode64!(private_key_base64)
      private_key_pem_decode = private_key
      |> :public_key.pem_decode()
      |> hd()
      |> :public_key.pem_entry_decode()

      options = rsa_padding_opts()
      aes_decrypted = :public_key.decrypt_private(aes, private_key_pem_decode, options)

      aes = aes_decrypted
      aad = <<>>
      tag = binary_slice(encrypted_data, (byte_size(encrypted_data) - gcm_tag_length)..byte_size(encrypted_data))
      ciphertext = binary_slice(encrypted_data, 0..(byte_size(encrypted_data) - gcm_tag_length - 1))

      decrypted = :crypto.crypto_one_time_aead(cipher, aes, iv, ciphertext, aad, tag, false)

      case decrypted do
        :error ->
          {:error, "Decrypt error"}

        decrypted ->
          {:ok, decrypted}
      end
    rescue
      _ ->
        {:error, "Decrypt error exception"}
    end
  end

  defp rsa_padding_opts() do
    [
      {:rsa_padding, :rsa_pkcs1_oaep_padding},
      {:rsa_oaep_md, :sha256},
      {:rsa_mgf1_md, :sha256}
    ]
  end
end
