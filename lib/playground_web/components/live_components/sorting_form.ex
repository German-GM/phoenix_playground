defmodule LynxwebWeb.LiveComponents.SortingForm do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :sort_by, :string
    field :sort_dir, Ecto.Enum, values: [:asc, :desc]
  end

  @default_values_transactions_dock_pay %{
    sort_by: "transaction_date",
    sort_dir: :desc
  }

  @default_values_reports_morpheus %{
    sort_by: "availability_date",
    sort_dir: :desc
  }

  @default_values_assignment_logs %{
    sort_by: "id",
    sort_dir: :desc
  }

  @default_values_embossing_file_logs %{
    sort_by: "id",
    sort_dir: :desc
  }

  @sort_by_values_transactions_dock_pay ["transaction_date"]

  @sort_by_values_assignment_logs [
    "id",
    "rango",
    "fecha",
    "hora",
    "id_usuario",
    "status",
    "username"
  ]

  @sort_by_values_embossing_file_logs [
    "id",
    "id_usuario",
    "tipo",
    "fecha",
    "hora",
    "status",
    "nombre_archivo",
    "cantidad",
    "embossing_file_id",
    "username"
  ]

  def changeset(schema, params, sort_by_values) do
    schema
    |> cast(params, [:sort_by, :sort_dir])
    |> validate_inclusion(:sort_by, sort_by_values)
    |> validate_inclusion(:sort_dir, [:asc, :desc])
  end

  def parse_assignment_logs(params) do
    changeset(
      struct(__MODULE__, @default_values_assignment_logs),
      params,
      @sort_by_values_assignment_logs
    )
    |> apply_action(:insert)
  end

  def parse_embossing_file_logs(params) do
    changeset(
      struct(__MODULE__, @default_values_embossing_file_logs),
      params,
      @sort_by_values_embossing_file_logs
    )
    |> apply_action(:insert)
  end

  defp convert_sort_dir(changeset) do
    case get_change(changeset, :sort_dir) do
      "asc" -> put_change(changeset, :sort_dir, :asc)
      "desc" -> put_change(changeset, :sort_dir, :desc)
      _ -> changeset
    end
  end

  def parse_reports_morpheus(params) do
    struct(__MODULE__, @default_values_reports_morpheus)
    |> cast(params, [:sort_by, :sort_dir])
    |> convert_sort_dir()
    |> validate_inclusion(:sort_dir, [:asc, :desc])
    |> apply_action(:insert)
  end

  def parse_transactions_dock_pay(params) do
    changeset(
      struct(__MODULE__, @default_values_transactions_dock_pay),
      params,
      @sort_by_values_transactions_dock_pay
    )
    |> apply_action(:insert)
  end

  def default_values_transactions_dock_pay(), do: @default_values_transactions_dock_pay
  def default_values_reports_morpheus(), do: @default_values_reports_morpheus
  def default_values_assignment_logs(), do: @default_values_assignment_logs
  def default_values_embossing_file_logs(), do: @default_values_embossing_file_logs
end
