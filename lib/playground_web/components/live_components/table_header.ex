defmodule LynxwebWeb.LiveComponents.TableHeader do
  use LynxwebWeb, :live_component

  alias Lynxweb.Utilities.Agnostic
  alias Agnostic.UIHelpers
  alias LynxwebWeb.EmbozadoLive.Forms.{FilterComponent}

  def mount(socket) do
    socket =
      socket
      |> UIHelpers.assign_form(%{})

    {:ok, socket}
  end

  def update(assigns, socket) do
    filters_data =
      assigns.filters_data
      |> Enum.map(fn {k, v} ->
        {k, Enum.map(v, fn value -> if value == "", do: "Sin dato", else: value end)}
      end)
      |> Enum.into(%{})

    socket =
      socket
      |> assign(assigns)
      |> assign_new(:disable, fn -> false end)
      # estado para mostrar o ocultar el listado de los filtros aplicados
      |> assign_new(:show_filters, fn -> false end)
      # estado para mostrar o ocultar el listado de las columnas
      |> assign_new(:show_columns, fn -> false end)
      # estado para mostrar o ocultar el botón de ocultar columnas
      |> assign_new(:button_hide_columns, fn -> false end)
      # estado para mostrar o ocultar el botón de mostrar columnas
      |> assign_new(:button_show_columns, fn -> true end)
      # estado para cambiar el texto del botón de guardar vista
      |> assign_new(:has_a_view, fn -> false end)
      # estado para almacenar los datos de las columnas
      |> assign_new(:column_data, fn -> %{} end)
      # estado para almacenar los datos de los filtros
      |> assign(:filters_data, filters_data)
      # estado para almacenar los datos de las columnas ocultas o activas
      |> assign_new(:filtered_column_data, fn -> nil end)
      # estado para manejar la opcion de mostrar algunas opciones dentro del componente
      |> assign_new(:hide_options, fn -> [] end)
      # estado para manejar el nombre que sera asignado al archivo exportado de excel
      |> assign_new(:file_name, fn -> "Archivo.xlsx" end)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex w-full flex-wrap gap-4">
      <div class="basis-auto flex-auto">
        <div class="h-min px-0 flex flex-wrap items-start gap-4">
          <!-- Exportar a Excel -->
          <div
            :if={!Enum.member?(assigns.hide_options, "export-xlsx")}
            class="grow"
          >
            <.file_exporter
              id="export-xlsx"
              action={~p"/lynx/export_xlsx"}
              filename={@file_name}
              btn_name="Exportar a Excel"
              phx-click="export-xlsx"
              styled_btn_icon="hero-document-text"
              styled_btn_color="secondary"
              class="w-full"
            />
          </div>
          <!-- Dropdown Columnas -->
          <div
            :if={!Enum.member?(assigns.hide_options, "btn-show-columns")}
            class="grow"
          >
            <.button
              class="whitespace-nowrap w-full p-2"
              phx-click="toggle_columns_dropdown"
              color="secondary"
              phx-target={@myself}
            >
              <.icon name="hero-bars-4" size="20px" /> Columnas
            </.button>
            <div
              :if={@show_columns and Enum.count(@column_data) > 0}
              id="filter-dropdown"
              class="flex flex-col z-10 absolute overflow-y-auto bg-white border border-gray-200 w-fit max-h-[360px] p-2"
              phx-click-away="close_columns_dropdown"
              phx-target={@myself}
            >
              <.form
                for={@form}
                id="value_search"
                phx-target={@myself}
                phx-change="filter_search_column"
                autocomplete="off"
              >
                <div class="min-w-[130px] max-w-full h-min p-1 flex flex-col gap-y-1 border-b border-[#ccc]">
                  <p class="text-[14px] font-medium">Busca columna:</p>
                  <.input
                    autofocus
                    type="text"
                    placeholder="Ingresar valor"
                    phx-debounce="500"
                    field={@form[:search]}
                  />
                </div>
              </.form>
              <div class="min-w-[130px] max-w-full h-max p-1 flex flex-col gap-y-1 border-b border-[#ccc]">
                <.button
                  :if={!@button_hide_columns}
                  type="submit"
                  class="w-full !py-0"
                  phx-click="hide_all_columns"
                  phx-target={@myself}
                >
                  Ocultar todas
                </.button>
                <.button
                  :if={!@button_show_columns}
                  type="submit"
                  class="w-full !py-0"
                  phx-click="show_all_columns"
                  phx-target={@myself}
                >
                  Activar todas
                </.button>
              </div>
              <%= for {column, visible} <- @filtered_column_data || @column_data do %>
                <div class="flex items-center gap-x-5 py-2">
                  <.switch
                    id={"switch-#{column}"}
                    name="column_value"
                    label={column}
                    checked={visible}
                    phx-target={@myself}
                    phx-click="toggle_column_visibility"
                    phx-value-column={column}
                  />
                </div>
              <% end %>
            </div>
          </div>
          <!-- Dropdown Filtros -->
          <div
            :if={!Enum.member?(assigns.hide_options, "btn-show-filters")}
            class="grow"
          >
            <.button
              class="whitespace-nowrap w-full p-2"
              phx-click="toggle_filters_dropdown"
              color="secondary"
              phx-target={@myself}
            >
              <.icon name="hero-adjustments-horizontal" size="20px" /> Filtros
            </.button>
            <div
              :if={@show_filters}
              id="filter-dropdown-header"
              class={
                if Enum.empty?(@filters_data),
                  do: "hidden",
                  else:
                    "flex flex-col z-10 absolute overflow-y-auto bg-white border border-gray-200 w-fit max-h-[340px] p-2"
              }
              phx-click-away="close_filters_dropdown"
              phx-target={@myself}
            >
              <%= for {key, values} <- @filters_data do %>
                <%= if Enum.count(values) > 0 do %>
                  <div class="py-2">
                    <p class="text-base border-b border-[#ccc]"><%= key %></p>
                    <div class="grid auto-rows-max grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-2 py-2">
                      <%= for value <- values do %>
                        <label
                          phx-click="delete_filter"
                          title="Eliminar filtro"
                          phx-value-data={Jason.encode!(%{value: value, column: key, values: values})}
                          phx-target={@myself}
                          class="cursor-pointer min-w-fit h-max gap-x-2 bg-gray-100 border border-[#ccc] p-2 rounded-lg text-gray-500 hover:border-primary hover:text-[#1e1e1e]"
                          style={"
                            #{if String.contains?(value, " ") || (!String.contains?(value, " ") and String.length(value) <= 16),
                            do: "word-break: initial;",
                            else: "word-break: break-all;"}
                          "}
                        >
                          <%= value %>
                        </label>
                      <% end %>
                    </div>
                  </div>
                <% end %>
              <% end %>
            </div>
          </div>
          <!-- Guardar Vista o Actualizar -->
          <div class="grow">
            <.button
              :if={!Enum.member?(assigns.hide_options, "btn-save-view")}
              class="whitespace-nowrap w-full p-2"
              phx-click="save_view"
              color="secondary"
              phx-target={@myself}
              disabled={@disable}
            >
              <%= if !@has_a_view do %>
                <.icon name="hero-clipboard-document-list" size="20px" /> Guardar vista
              <% else %>
                <.icon name="hero-arrow-path" size="20px" /> Actualizar vista
              <% end %>
            </.button>
          </div>
        </div>
      </div>

      <!-- Filtros de Fecha y ID -->
      <div
        :if={!Enum.member?(assigns.hide_options, "filter-component")}
        class="w-full sm:w-auto sm:ml-auto basis-auto flex flex-nowrap"
      >
        <.live_component
          module={FilterComponent}
          id="filter"
          filter={@filter}
          show_dates={@show_dates}
          show_id={@show_id}
          button_disabled={@button_disabled}
        />
      </div>
    </div>
    """
  end

  # Evento para mostrar el listado de filtros
  def handle_event("toggle_filters_dropdown", _params, socket) do
    {:noreply, assign(socket, :show_filters, true)}
  end

  # Evento para mostrar el listado de columnas
  def handle_event("toggle_columns_dropdown", _params, socket) do
    if Enum.count(socket.assigns.column_data) == 0 do
      {:noreply, socket}
    else
      {:noreply, assign(socket, :show_columns, true)}
    end
  end

  # Evento para cerrar el listado de filtros
  def handle_event("close_filters_dropdown", _params, socket) do
    {:noreply, assign(socket, :show_filters, false)}
  end

  # Evento para cerrar el listado de columnas
  def handle_event("close_columns_dropdown", _params, socket) do
    socket =
      socket
      |> assign(:filtered_column_data, nil)
      |> assign(:show_columns, false)

    {:noreply, socket}
  end

  # Evento para eliminar un filtro aplicado
  def handle_event("delete_filter", %{"data" => data}, socket) do
    %{"value" => value, "column" => column, "values" => values} = Jason.decode!(data)
    Debug.print(data, label: "data")
    Debug.print(value, label: "value")
    Debug.print(column, label: "column")

    updated_values = Enum.reject(values, fn v -> v == value end)
    Debug.print(updated_values, label: "updated_values")

    send(
      self(),
      {:filter_table,
       %{column: column, values: updated_values, action: :remove, value_to_remove: value}}
    )

    {:noreply, socket}
  end

  # Evento para ocultar o mostrar una columna
  def handle_event("toggle_column_visibility", %{"column" => column}, socket) do
    column_data = socket.assigns.column_data
    new_visibility = Map.update!(column_data, column, &(!&1))

    # new_visibility =
    #   cond do
    #     column == "ID Archivo Embozado" and not new_visibility[column] ->
    #       Map.put(new_visibility, "Acciones", false)

    #     column == "ID Archivo Embozado" and new_visibility[column] ->
    #       Map.put(new_visibility, "Acciones", true)

    #     column == "Acciones" and new_visibility[column] ->
    #       Map.put(new_visibility, "ID Archivo Embozado", true)

    #     true ->
    #       new_visibility
    #   end

    send(self(), {:show_columns, %{value: new_visibility, column: column}})

    all_columns_hidden = Enum.all?(new_visibility, fn {_k, v} -> not v end)

    socket =
      socket
      |> assign(:column_data, new_visibility)
      |> assign(:filtered_column_data, nil)
      |> assign(:button_hide_columns, all_columns_hidden)
      |> assign(:button_show_columns, not all_columns_hidden)

    {:noreply, socket}
  end

  # Evento para buscar una columna
  def handle_event("filter_search_column", %{"search" => search_term}, socket) do
    column_data = socket.assigns.column_data

    filtered_columns =
      column_data
      |> Enum.filter(fn {column, _visible} ->
        String.contains?(String.downcase(column), String.downcase(search_term))
      end)
      |> Enum.into(%{})

    {:noreply, assign(socket, :filtered_column_data, filtered_columns)}
  end

  # Evento para ocultar todas las columnas
  def handle_event("hide_all_columns", _params, socket) do
    new_visibility =
      Enum.into(socket.assigns.column_data, %{}, fn {column, _visible} -> {column, false} end)

    Debug.print(socket.assigns.column_data, label: "column_data")
    Debug.print(new_visibility, label: "new_visibility")

    send(self(), {:show_or_hide_columns, %{value: new_visibility}})

    socket =
      socket
      |> assign(:button_hide_columns, true)
      |> assign(:button_show_columns, false)
      |> assign(:column_data, new_visibility)

    {:noreply, socket}
  end

  # Evento para mostrar todas las columnas
  def handle_event("show_all_columns", _params, socket) do
    new_visibility =
      Enum.into(socket.assigns.column_data, %{}, fn {column, _visible} -> {column, true} end)

    Debug.print(socket.assigns.column_data, label: "column_data")
    Debug.print(new_visibility, label: "new_visibility")

    send(self(), {:show_or_hide_columns, %{value: new_visibility}})

    socket =
      socket
      |> assign(:button_show_columns, true)
      |> assign(:button_hide_columns, false)
      |> assign(:column_data, new_visibility)

    {:noreply, socket}
  end

  # Evento para guardar la vista
  def handle_event("save_view", _params, socket) do
    send(self(), {:save_view})
    {:noreply, socket}
  end
end
