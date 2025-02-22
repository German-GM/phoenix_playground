defmodule LynxwebWeb.LiveComponents.Priority do
  use LynxwebWeb, :live_component

  def update(assigns, socket) do
    priority_columns = assigns.priority_columns || %{}

    columns =
      case assigns.column do
        atom when is_atom(atom) -> [atom]
        list when is_list(list) -> list
        string when is_binary(string) -> [string]
        _ -> []
      end

    priority_filter =
      columns
      |> Enum.map(fn column ->
        column_str =
          if Map.get(assigns, :cadena, true) do
            column
          else
            Atom.to_string(column)
          end

        %{
          column_str => %{
            "PR" => Map.get(priority_columns["PR"], column_str, false),
            "PI" => Map.get(priority_columns["PI"], column_str, false)
          }
        }
      end)

    socket =
      socket
      |> assign(assigns)
      |> assign(:priority_filter, priority_filter)
      |> assign_new(:show_priority, fn -> true end)
      # este atributo esteblece el tipo de prioridad que manejara cada columna PR, PI o ambas
      |> assign_new(:type_priority, fn -> [] end)
      |> assign_new(:show_priority_filters, fn -> false end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center">
      <%= if @show_priority do %>
        <%= if !@show_priority_filters do %>
          <button
            title="Mostrar opciones de prioridad"
            phx-click="show_priority_filters"
            id={"show-#{System.unique_integer()}"}
            phx-value-show="true"
            phx-value-column={@column}
            phx-target={@myself}
            phx-capture-click
          >
            <.icon name="hero-eye" size="16px" class="bg-secondary hover:bg-primary cursor-pointer" />
          </button>
        <% else %>
          <%= case @type_priority do %>
            <% ["PR"] -> %>
              <div>
                <button
                  title="Prioridad por rango"
                  id={"PR-#{@column}"}
                  class={icon_class("PR", @priority_filter, @column, @cadena)}
                  phx-click="change_priority"
                  phx-value-column={@column}
                  phx-value-filter="PR"
                  phx-target={@myself}
                  phx-capture-click
                >
                  PR
                </button>
              </div>
            <% ["PI"] -> %>
              <div>
                <button
                  title="Prioridad individual"
                  id={"PI-#{@column}"}
                  class={icon_class("PI", @priority_filter, @column, @cadena)}
                  phx-click="change_priority"
                  phx-value-column={@column}
                  phx-value-filter="PI"
                  phx-target={@myself}
                  phx-capture-click
                >
                  PI
                </button>
              </div>
            <% ["PR", "PI"] -> %>
              <div>
                <button
                  title="Prioridad por rango"
                  id={"PR-#{@column}"}
                  class={icon_class("PR", @priority_filter, @column, @cadena)}
                  phx-click="change_priority"
                  phx-value-column={@column}
                  phx-value-filter="PR"
                  phx-target={@myself}
                  phx-capture-click
                >
                  PR
                </button>
                <span>|</span>
                <button
                  title="Prioridad individual"
                  id={"PI-#{@column}"}
                  class={icon_class("PI", @priority_filter, @column, @cadena)}
                  phx-click="change_priority"
                  phx-value-column={@column}
                  phx-value-filter="PI"
                  phx-target={@myself}
                  phx-capture-click
                >
                  PI
                </button>
              </div>
          <% end %>

          <div>
            <button
              phx-click="show_priority_filters"
              phx-value-show="false"
              phx-value-column={@column}
              id={"hide-#{System.unique_integer()}"}
              phx-target={@myself}
              title="Ocultar opciones de prioridad"
              class="ml-2"
              phx-capture-click
            >
              <.icon
                name="hero-eye-slash"
                size="16px"
                class="bg-secondary hover:bg-primary cursor-pointer"
              />
            </button>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  def handle_event("show_priority_filters", %{"show" => value, "column" => _column}, socket) do
    socket =
      case value do
        "true" -> assign(socket, :show_priority_filters, true)
        "false" -> assign(socket, :show_priority_filters, false)
      end

    {:noreply, socket}
  end

  def handle_event("change_priority", %{"filter" => selected_filter, "column" => column}, socket) do
    priority_filter = socket.assigns.priority_filter
    priority_columns = socket.assigns.priority_columns

    send(self(), {:loading})

    Debug.print(priority_filter, label: "priority_filter")
    Debug.print(priority_columns, label: "priority_columns")

    column_str =
      if is_atom(column) and !socket.assigns.cadena, do: Atom.to_string(column), else: column

    Debug.print(column_str, label: "COLUMNA EN PRIORITY PR/PI")

    updated_priority_filter =
      Enum.map(priority_filter, fn map ->
        if Map.has_key?(map, column_str) do
          current_filter = Map.get(map, column_str)

          updated_filter =
            if Map.get(current_filter, selected_filter, false) do
              Map.put(current_filter, selected_filter, false)
            else
              current_filter
              |> Map.put(selected_filter, true)
              |> Map.put(opposite_filter(selected_filter), false)
            end

          %{column_str => updated_filter}
        else
          map
        end
      end)

    updated_priority_columns =
      priority_columns
      |> Map.update!(selected_filter, fn value_map ->
        case Map.get(value_map, column_str, false) do
          true -> Map.put(value_map, column_str, false)
          false -> Map.put(value_map, column_str, true)
        end
      end)
      |> Map.update!(opposite_filter(selected_filter), fn value_map ->
        if Map.get(value_map, column_str, false) do
          Map.put(value_map, column_str, false)
        else
          value_map
        end
      end)

    send(self(), {:change_priority, %{priority_columns: updated_priority_columns}})

    socket =
      socket
      |> assign(:priority_filter, updated_priority_filter)
      |> assign(:priority_columns, updated_priority_columns)

    {:noreply, socket}
  end

  defp opposite_filter("PR"), do: "PI"
  defp opposite_filter("PI"), do: "PR"

  defp icon_class(filter, priority_filter, column, cadena) do
    column_str =
      if cadena do
        column
      else
        Atom.to_string(column)
      end

    case Enum.find(priority_filter, fn map -> Map.has_key?(map, column_str) end) do
      %{^column_str => filter_map} ->
        if Map.get(filter_map, filter, false) do
          "text-primary cursor-pointer font-medium underline"
        else
          "text-secondary hover:text-primary cursor-pointer"
        end

      _ ->
        "text-secondary hover:text-primary cursor-pointer"
    end
  end
end
