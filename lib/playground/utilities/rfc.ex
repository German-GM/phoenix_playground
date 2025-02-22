defmodule Playground.Utilities.RFC do
  @doc """
  Extrae la fecha de constitución de una empresa a partir de su RFC.
  """
  def fecha_constitucion(rfc) when is_binary(rfc) do
    case String.length(rfc) do
      12 -> parse_fecha(String.slice(rfc, 3, 6))
      13 -> parse_fecha(String.slice(rfc, 3, 6))
      _ -> {:error, "RFC inválido"}
    end
  end

  defp parse_fecha(<<year::binary-size(2), month::binary-size(2), day::binary-size(2)>>) do
    year = String.to_integer(year)
    year = if year >= 0 and year <= 21, do: 2000 + year, else: 1900 + year
    month = String.to_integer(month)
    day = String.to_integer(day)

    case Date.new(year, month, day) do
      {:ok, date} -> {:ok, date}
      {:error, _} -> {:error, "Fecha inválida"}
    end
  end
end
