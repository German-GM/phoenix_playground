defmodule LynxwebWeb.LiveComponents.SortingCardsForm do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :sort_by, :string
    field :sort_dir, Ecto.Enum, values: [:asc, :desc]
  end

  @default_values %{
    sort_by: "consecutivo",
    sort_dir: :asc
  }

  @sort_by_values [
    "id_card",
    "used",
    "masked_pan",
    "id",
    "id_file_embossing",
    "fecha",
    "hora",
    "factory_nip",
    "idusuario",
    "consecutivo",
    "selected",
    "sucursal",
    "card_id",
    "tipo",
    "idsocio",
    "person_id",
    "account_id",
    "numero_socio",
    "socio_nombre_completo",
    "username"
  ]

  def changeset(schema, params) do
    schema
    |> cast(params, [:sort_by, :sort_dir])
    |> validate_inclusion(:sort_by, @sort_by_values)
    |> validate_inclusion(:sort_dir, [:asc, :desc])
  end

  def parse(params) do
    changeset(struct(__MODULE__, @default_values), params)
    |> apply_action(:insert)
  end

  def default_values(), do: @default_values
end
