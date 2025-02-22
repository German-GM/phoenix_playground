defmodule Playground.Utilities.Agnostic.Format do
  @moduledoc """
  Módulo con funciones relacionadas a formato de datos (números, cadenas, fechas, etc).
  """
  alias Playground.Utilities.Agnostic.Regexp

  # -----------------------
  # FECHA/HORA
  # -----------------------
  def iso8601_datetime_to_local(iso8601_datetime) do
    timex_format = "{0D}/{0M}/{YYYY} {h12}:{m}:{s} {am}"

    with {:ok, datetime, _offset} <- DateTime.from_iso8601(iso8601_datetime),
        local_tz <- Timex.Timezone.Local.lookup(),
        local_datetime <- Timex.to_datetime(datetime, local_tz),
        {:ok, result} <- Timex.format(local_datetime, timex_format)
    do
      result
    else
      {:error, error} ->
        {:error, error}
    end
  end

  def is_date?(any) do
    cond do
      is_binary(any) ->
        case NaiveDateTime.from_iso8601(any) do
          {:ok, _naive_datetime} -> true
          {:error, _} ->
            case DateTime.from_iso8601(any) do
              {:ok, _datetime, _offset} -> true
              {:error, _} -> false
            end
        end

      is_struct(any, Date) or is_struct(any, Time) or is_struct(any, DateTime) or is_struct(any, NaiveDateTime) ->
        true

      true ->
        false
    end
  end

  def current_utc_date() do
    DateTime.utc_now()
    |> DateTime.to_date()
  end

  @spec current_utc_date_add(integer()) :: Date.t()
  def current_utc_date_add(days) do
    current_utc_date()
    |> Date.add(days)
  end

  def current_utc_time() do
    DateTime.utc_now()
    |> DateTime.to_time()
    |> Time.truncate(:second)
  end

  @spec current_utc_time_add(integer(), :second | :minute | :hour | :day) :: Time.t()
  def current_utc_time_add(amount, unit \\ :second) do
    current_utc_time()
    |> Time.add(amount, unit)
  end

  def current_utc_datetime() do
    DateTime.utc_now()
    |> DateTime.to_iso8601()
  end

  @spec current_utc_datetime_add(integer(), :second | :minute | :hour | :day) :: String.t()
  def current_utc_datetime_add(amount, unit \\ :second) do
    DateTime.utc_now()
    |> DateTime.add(amount, unit)
    |> DateTime.to_iso8601()
  end

  # -----------------------
  # CADENAS
  # -----------------------
  def trim_all_spaces_to_one(string),
    do: string |> String.replace(Regexp.more_than_one_space(), " ")

  def trim_all_spaces(string), do: string |> String.replace(Regexp.blank_spaces(), "")

  @doc """
  Intenta convertir un entero a cadena. Si no es posible, devuelve el valor original.
  """
  def try_parse_integer_to_string(integer) when is_integer(integer) do
    Integer.to_string(integer)
  end

  def try_parse_integer_to_string(any), do: any

  # -----------------------
  # NUMEROS
  # -----------------------
  @doc """
  Intenta convertir una cadena a entero. Si no es posible, devuelve el valor original.
  Si la cadena que se intenta convertir no es un entero, lanza una excepción.
  """
  def try_parse_string_to_integer(string) when is_binary(string) do
    String.to_integer(string)
  end

  def try_parse_string_to_integer(any), do: any

  @doc """
  Devuelve un número con un máximo de 2 decimales.

  Solo utilizada para limitar decimales y realizar cálculos manteniendo la precisión de 2 decimales,
  o para encadenar con otras funciones (ej. thousand_separator() o currency()) para obtener un formato de
  cadena específico.

  ## Ejemplos
      iex> Playground.Utilities.Agnostic.Format.max_dec_2("12.534")
      12.53

      iex> Playground.Utilities.Agnostic.Format.max_dec_2(12.535)
      12.54
  """
  def max_dec_2(value),
    do: precision_round(value, 2)

  @doc """
  Devuelve un número con un máximo de 6 decimales.

  Solo utilizada para limitar decimales y realizar cálculos manteniendo la precisión de 6 decimales,
  o para encadenar con otras funciones (ej. thousand_separator() o currency()) para obtener un formato de
  cadena específico.

  ## Ejemplos
      iex> Playground.Utilities.Agnostic.Format.max_dec_6("12.3333334")
      12.333333

      iex> Playground.Utilities.Agnostic.Format.max_dec_6(12.3333335)
      12.333334
  """
  def max_dec_6(value),
    do: precision_round(value, 6)

  # -----------------------
  # MONEDA O RELACIONADO
  # -----------------------
  @doc """
  Devuelve una cadena con separador de miles. Se omiten los decimales si vienen en 0.

  ## Ejemplos
      iex> Playground.Utilities.Agnostic.Format.thousand_separator("1200")
      "1,200"

      iex> Playground.Utilities.Agnostic.Format.thousand_separator(1200.00)
      "1,200"

      iex> Playground.Utilities.Agnostic.Format.thousand_separator(1200.36)
      "1,200.36"

      iex> Playground.Utilities.Agnostic.Format.thousand_separator("invalid")
      "0"

      iex> Playground.Utilities.Agnostic.Format.thousand_separator(nil)
      "0"
  """
  def thousand_separator(value) do
    # Se usan 10 decimales para tener mas soltura y que no se aplique un redondeo no deseado
    # y también para que no salga con un formato incorrecto (ej. 120000 -> 1.2e5)
    # La opción :compact quita los ceros a la derecha (ej. 29.1500000000 -> 29.15)
    decimals = 10

    value
    |> force_float()
    |> :erlang.float_to_binary([:compact, decimals: decimals])
    |> String.split(".")
    |> then(fn [int_part, dec_part] ->
      int_part = Regex.replace(~r/(?<=\d)(?=(\d{3})+$)/, int_part, ",")
      dec_part = case dec_part do
        dec when byte_size(dec) == 1 -> dec_part <> "0"
        _ -> dec_part
      end

      if dec_part == "00" do
        int_part
      else
        "#{int_part}.#{dec_part}"
      end
    end)
  end

  @doc """
  Convierte un número en una cadena con formato de moneda con un mínimo de 2 decimales.

  ## Ejemplos
      iex> Playground.Utilities.Agnostic.Format.currency("1200")
      "$1,200.00"

      iex> Playground.Utilities.Agnostic.Format.currency(1200.36)
      "$1,200.36"

      iex> Playground.Utilities.Agnostic.Format.currency("invalid")
      "$0.00"

      iex> Playground.Utilities.Agnostic.Format.currency(nil)
      "$0.00"
  """
  def currency(number, moneda \\ "MXN") do
    decimals = 2

    number_str = number
    |> precision_round(decimals)
    |> :erlang.float_to_binary(decimals: decimals)

    # Separadores de miles
    number_str =
      number_str
      |> String.split(".")
      |> then(fn [int_part, dec_part] ->
        int_part = Regex.replace(~r/(?<=\d)(?=(\d{3})+$)/, int_part, ",")
        dec_part = case dec_part do
          dec when byte_size(dec) == 1 -> dec_part <> "0"
          _ -> dec_part
        end

         "#{int_part}.#{dec_part}"
      end)

    # Formato por tipo de moneda
    case moneda do
      "MXN" -> "$#{number_str}"
      "EUR" -> "#{number_str} €"
      moneda when is_nil(moneda) or byte_size(moneda) == 0 -> number_str
      _ -> "$#{number_str} #{moneda}"
    end
  end

  @doc """
  Convierte un número (o cadena si se traduce a un número válido) en una cadena con formato de moneda
  con un mínimo de 2 decimales junto con su representación en letra.

  ## Ejemplos
      iex> Playground.Utilities.Agnostic.Format.currency_to_words("1200")
      "$1,200.00 (UN MIL DOSCIENTOS PESOS 0/100 M.N.)"

      iex> Playground.Utilities.Agnostic.Format.currency_to_words(1200.36)
      "$1,200.36 (UN MIL DOSCIENTOS PESOS 36/100 M.N.)"

      iex> Playground.Utilities.Agnostic.Format.currency_to_words(0.42)
      "$0.42 (CERO PESOS 42/100 M.N.)"

      iex> Playground.Utilities.Agnostic.Format.currency_to_words(0)
      "$0.00 (CERO PESOS 0/100 M.N.)"

      iex> Playground.Utilities.Agnostic.Format.currency_to_words("invalid")
      :invalid_format

      iex> Playground.Utilities.Agnostic.Format.currency_to_words(nil)
      :invalid_format
  """
  def currency_to_words(number, moneda \\ "MXN") do
    number =
      case number do
        value when is_number(value) ->
          force_float(number)

        value when is_binary(value) ->
          case Float.parse(to_string(value)) do
            {num, _} -> force_float(num)
            :error -> nil
          end

        _ ->
          nil
      end

    if is_nil(number) do
      :invalid_format
    else
      case number_to_words(number, moneda) do
        {:ok, num_letra, centavos_letra, _centavos} ->
          formatted_saldo =
            "#{currency(number)} (#{num_letra} #{centavos_letra})"

          formatted_saldo |> trim_all_spaces_to_one()

        {:error, error} ->
          error
      end
    end
  end

  defp number_to_words(num, moneda) do
    letras_moneda_plural =
      case moneda do
        "MXN" -> "PESOS"
        "USD" -> "DOLARES AMERICANOS"
        _ -> moneda
      end

    letras_moneda_singular =
      case moneda do
        "USD" -> "DOLAR AMERICANO"
        _ -> "PESO"
      end

    enteros = trunc(num)
    limite_numero = 999_999_999_999.99 # En base a la función miles_millones() y al límite de representación de 2 decimales
    centavos = rem(round(num * 100), 100)
    centavos_letra = "#{centavos}/100#{if moneda == "MXN", do: " M.N.", else: ""}"

    num_letra = cond do
      enteros == 0 -> "CERO " <> letras_moneda_plural
      enteros == 1 -> miles_millones(enteros) <> " " <> letras_moneda_singular
      true -> miles_millones(enteros) <> " " <> letras_moneda_plural
    end

    if num > limite_numero do
      {:error, "Error: no se tiene soporte para números igual o mayores a #{num}"}
    else
      {:ok, num_letra, centavos_letra, centavos}
    end
  end

  defp unidades(num) do
    case num do
      1 -> "UN"
      2 -> "DOS"
      3 -> "TRES"
      4 -> "CUATRO"
      5 -> "CINCO"
      6 -> "SEIS"
      7 -> "SIETE"
      8 -> "OCHO"
      9 -> "NUEVE"
      _ -> ""
    end
  end

  defp decenas(num) do
    decena = div(num, 10)
    unidad = rem(num, 10)

    case decena do
      1 ->
        case unidad do
          0 -> "DIEZ"
          1 -> "ONCE"
          2 -> "DOCE"
          3 -> "TRECE"
          4 -> "CATORCE"
          5 -> "QUINCE"
          _ -> "DIECI" <> unidades(unidad)
        end
      2 ->
        case unidad do
          0 -> "VEINTE"
          _ -> "VEINTI" <> unidades(unidad)
        end
      3 -> decenas_y("TREINTA", unidad)
      4 -> decenas_y("CUARENTA", unidad)
      5 -> decenas_y("CINCUENTA", unidad)
      6 -> decenas_y("SESENTA", unidad)
      7 -> decenas_y("SETENTA", unidad)
      8 -> decenas_y("OCHENTA", unidad)
      9 -> decenas_y("NOVENTA", unidad)
      _ -> unidades(unidad)
    end
  end

  defp decenas_y(str_sin, num_unidades) do
    if num_unidades > 0 do
      str_sin <> " Y " <> unidades(num_unidades)
    else
      str_sin
    end
  end

  defp centenas(num) do
    centenas = div(num, 100)
    decenas = rem(num, 100)

    case centenas do
      1 ->
        if decenas > 0 do
          "CIENTO " <> decenas(decenas)
        else
          "CIEN"
        end
      2 -> "DOSCIENTOS " <> decenas(decenas)
      3 -> "TRESCIENTOS " <> decenas(decenas)
      4 -> "CUATROCIENTOS " <> decenas(decenas)
      5 -> "QUINIENTOS " <> decenas(decenas)
      6 -> "SEISCIENTOS " <> decenas(decenas)
      7 -> "SETECIENTOS " <> decenas(decenas)
      8 -> "OCHOCIENTOS " <> decenas(decenas)
      9 -> "NOVECIENTOS " <> decenas(decenas)
      _ -> decenas(decenas)
    end
  end

  defp seccion(num, divisor, str_singular, str_plural) do
    cientos = div(num, divisor)
    resto = rem(num, divisor)

    letras = if cientos > 0 do
      if cientos > 1 do
        centenas(cientos) <> " " <> str_plural
      else
        str_singular
      end
    else
      ""
    end

    if (resto > 0) do
      letras <> ""
    else
      letras
    end
  end

  defp miles(num) do
    divisor = 1000
    resto = rem(num, divisor)
    str_miles = seccion(num, divisor, "UN MIL", "MIL")
    str_centenas = centenas(resto)

    cond do
      str_miles == "" -> str_centenas
      true -> str_miles <> " " <> str_centenas
    end
  end

  defp millones(num) do
    divisor = 1_000_000
    resto = rem(num, divisor)
    str_millones = seccion(num, divisor, "UN MILLON", "MILLONES")
    str_miles = miles(resto)

    cond do
      str_millones == "" -> str_miles
      true -> str_millones <> " " <> str_miles
    end
  end

  defp miles_millones(num) do
    divisor = 1_000_000_000
    resto = rem(num, divisor)
    str_mil_millones = seccion(num, divisor, "UN MIL MILLON", "MIL MILLONES")
    str_millones = millones(resto)

    cond do
      str_mil_millones == "" -> str_millones
      true -> str_mil_millones <> " " <> str_millones
    end
  end

  # Función solamente utilizada para hacer composición en otras funciones.
  # Depende de la función local privada "force_float()"

  # Convierte cualquier dato en un número con un máximo de decimales especificado,
  # solucionando los problemas de precisión y redondeo.
  # ## Ejemplos
  #     0.1 + 0.2 = 0.30000000000000004
  #     iex> Playground.Utilities.Agnostic.Format.precision_round(0.1 + 0.2)
  #     0.3

  #     iex> Playground.Utilities.Agnostic.Format.precision_round(1.115, 2)
  #     1.12

  #     :erlang.float_to_binary(2.3375, decimals: 3) = 2.337
  #     iex> Playground.Utilities.Agnostic.Format.precision_round(2.3375, 3)
  #     2.338
  defp precision_round(value, decimals) do
    num = force_float(value)
    str = to_string(num)

    [_integer_part, decimal_part] = String.split(str, ".")

    # Ej. value: 2.3375, decimals: 3, decimal_limit tendrá el valor de "5"
    # Ej. value: 52.1, decimals: 3, decimal_limit tendrá el valor de nil
    decimal_limit = String.at(decimal_part, decimals)

    # Redondear decimales siempre hacia arriba si el decimal siguiente al límite especificado es igual a 5 (ej. límite 3 decimales, valor 2.3375)
    # Para valores > 5 :erlang.float_to_binary() ya se encarga de redondear hacia arriba
    # Checar si nos conviente redondear decimales de esta forma o si aplicamos el redondeo "Round Half to Even"
    num = if decimal_limit == "5" do
      num + 1 / :math.pow(10, decimals + 1)
    else
      num
    end

    :erlang.float_to_binary(num, decimals: decimals)
    |> String.to_float()
  end

  # Función solamente utilizada para hacer composición en otras funciones.
  # Convierte cualquier valor en un número flotante. Si no es posible, devuelve 0.0.
  # ## Ejemplos
  #     iex> Playground.Utilities.Agnostic.Format.force_float("123")
  #     123.0

  #     iex> Playground.Utilities.Agnostic.Format.force_float(45.6799)
  #     45.6799

  #     iex> Playground.Utilities.Agnostic.Format.force_float("invalid")
  #     0.0

  #     iex> Playground.Utilities.Agnostic.Format.force_float(nil)
  #     0.0
  defp force_float(value) do
    case Float.parse(to_string(value)) do
      {num, _} -> num
      :error -> 0.0
    end
  end

end
