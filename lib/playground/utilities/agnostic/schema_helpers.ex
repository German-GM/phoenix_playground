defmodule Playground.Utilities.Agnostic.SchemaHelpers do
  import Ecto.Changeset

  @doc """
  Transforma los errores de changeset a un mapa de mensajes.
    %{password: ["password is too short"]} = SchemaHelpers.format_changeset_errors(changeset)
  """
  def format_changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {message, opts} ->
      Regex.replace(~r"%{(\w+)}", message, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end

  @doc """
  Formatea errores determinados de un changeset a español.
  """
  def translate_changeset_errors(changeset) do
    update_in changeset.errors, &Enum.map(&1, fn
      {key, {"can't be blank", rules}} -> {key, {"Dato requerido", rules}}
      {key, {"is invalid", rules}} -> {key, {"Tipo de dato no válido", rules}}
      {key, {"should have at least %{count} item(s)", rules}} -> {key, {"Debe tener al menos #{rules[:count]} elemento", rules}}
      {key, {"should be at most %{count} character(s)", rules}} -> {key, {"Debe tener máximo #{rules[:count]} caracteres", rules}}
      {key, {"should be at least %{count} character(s)", rules}} -> {key, {"Debe tener mínimo #{rules[:count]} caracteres", rules}}
      {key, {"should be %{count} character(s)", rules}} -> {key, {"Debe tener #{rules[:count]} caracteres", rules}}
      {key, {"has invalid format", rules}} -> {key, {"Formato no válido", rules}}

      tuple  -> tuple
    end)
  end

  def validate_date_range(changeset, start_date_field, end_date_field) do
    start_date = get_field(changeset, start_date_field)
    end_date = get_field(changeset, end_date_field)

    cond do
      end_date && start_date == nil ->
        # la fecha de inicio es requerida si la fecha de fin está presente
        add_error(changeset, start_date_field, "La fecha de inicio es requerida")

      start_date && end_date == nil ->
        # la fecha de fin es requerida si la fecha de inicio está presente
        add_error(changeset, end_date_field, "La fecha de fin es requerida")

      start_date && end_date && Date.compare(start_date, end_date) == :gt ->
        # debe ser después o igual a la fecha de inicio
        add_error(changeset, end_date_field, "Fecha inválida")

      start_date && end_date && Date.compare(end_date, start_date) == :lt ->
        # debe ser antes o igual a la fecha de fin
        add_error(changeset, start_date_field, "Fecha inválida")

      true ->
        changeset
    end
  end
end
