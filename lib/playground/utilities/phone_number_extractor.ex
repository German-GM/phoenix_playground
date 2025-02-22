defmodule Playground.Utilities.PhoneNumberExtractor do
  def extract_numbers(phone_numbers) do
    Enum.map(phone_numbers, &extract_number/1)
  end

  # Obtiene el puro número de teléfono sin caracteres adicionales o espacios en blanco
  # Ej. "(321)102-14-44" -> "3211021444"
  # Ej. "( ) - - " -> ""
  def get_number(phone_number) do
    phone_chars_regex = ~r/[\(\)\-\s]/
    phone_number
    |> String.replace(phone_chars_regex, "")
  end

  defp extract_number(phone_number) do
    case Regex.run(~r/\((\d{1,3})\)(\d{3})-(\d{2})-(\d{2})/, phone_number) do
      [_, area_code, first_part, second_part, third_part] ->
        case String.slice(area_code, 0..1) do
          "3" -> adjust_number("3", area_code, first_part, second_part, third_part)
          "33" -> adjust_number("33", area_code, first_part, second_part, third_part)
          "55" -> adjust_number("55", area_code, first_part, second_part, third_part)
          "81" -> adjust_number("81", area_code, first_part, second_part, third_part)
          _ -> {area_code, first_part <> second_part <> third_part}
        end

      _ ->
        {nil, nil}
    end
  end

  defp adjust_number(area_code, full_area_code, first_part, second_part, third_part) do
    remaining_part =
      if String.length(full_area_code) > 2 do
        String.at(full_area_code, 2) <> first_part
      else
        first_part
      end

    {area_code, remaining_part <> second_part <> third_part}
  end
end
