defmodule Debug do
  # Activa o desactiva las funciones debug de forma global
  @global_debug_active true

  def write_to_log_file(any) do
    if dev_env?() do
      # Convertir la estructura a una cadena
      to_string = inspect(any)

      # Añadir una nueva línea al final de la cadena para que cada log se escriba en una nueva línea
      to_string = "#{to_string}\n"

      # Escribir la cadena en un archivo
      case File.write("log.txt", to_string, [:append]) do
        :ok ->
          IO.puts("Log data written to file successfully.")
        {:error, reason} ->
          IO.puts("Failed to write log data to file: #{reason}")
      end
    end
  end

  def sleep(ms) do
    dev_env?() && Process.sleep(ms)
  end

  # limit: :infinity, imprime todos los elementos, default: 50
  def print(arg, opts \\ []) do
    if dev_env?() do
      if opts[:kernel] do
        opts = opts
        |> Enum.concat([pretty: true])

        label = if is_binary(opts[:label]), do: String.trim(opts[:label]), else: ""
        label = if label != "", do: "#{label}: ", else: ""

        "#{label}#{inspect(arg, opts)}"
      else
        opts = opts
        |> Enum.concat([
          syntax_colors: [
            string: :green,
            number: :yellow,
            boolean: :red,
            list: :magenta,
            map: :magenta,
            nil: :red,
            atom: :blue
          ]
        ])

        IO.puts("\n")
        IO.inspect(arg, opts)
      end
    end
  end

  def show_log_id_processes_to_save() do
    default_to_save = Playground.Utilities.Agnostic.ApiHelpers.default_log_id_processes_to_save()
    additional_to_save = Playground.Utilities.Agnostic.ApiHelpers.additional_log_id_processes_to_save()
    final_to_save = Playground.Utilities.Agnostic.ApiHelpers.log_id_processes_to_save()

    %{
      "1_DEFAULT_TO_SAVE (#{length(default_to_save)})" => default_to_save,
      "2_ADDITIONAL_TO_SAVE (#{length(additional_to_save)})" => additional_to_save,
      "3_FINAL_TO_SAVE (#{length(final_to_save)})" => final_to_save
    }
  end

  def dev_env?() do
    (Env.dev_env?() || Env.debug_mode?())
      && @global_debug_active
  end
end
