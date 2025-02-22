defmodule LynxwebWeb.LiveComponents.FilterTables do
  use LynxwebWeb, :live_component

  alias LynxwebWeb.EmbozadoLive.Forms.{RangeSearchUtils}
  alias Lynxweb.Utilities.Agnostic
  alias Agnostic.UIHelpers

  def mount(socket) do
    changeset = RangeSearchUtils.changeset(%RangeSearchUtils{})

    socket =
      socket
      |> UIHelpers.assign_form(changeset, :form_range)
      |> UIHelpers.assign_form(%{})
      |> assign(:loading, false)
      |> assign(:errors, %{})

    {:ok, socket}
  end

  def update(assigns, socket) do
    # Debug.print(socket, label: "Socket assigns")

    fixed_filters = assigns[:fixed_filters] || []

    socket =
      socket
      |> assign(assigns)
      |> assign_new(:column, fn -> "default_column_name" end)
      # estado para mostrar o ocultar los filtros
      |> assign_new(:show_filters, fn -> false end)
      # estado para manejar la carga inicial de los datos de los filtros
      |> assign_new(:column_data_loaded, fn -> false end)
      # estado para manejar los valores seleccionados por columna
      |> assign_new(:selected_values, fn -> [] end)
      # estado para manejar si una columna tiene habilitado el filtro de busqueda
      |> assign_new(:search_enabled, fn -> false end)
      # estado para manejar si una columna tiene habilitado el filtro de rango
      |> assign_new(:range_enabled, fn -> false end)
      # estado para manejar si el boton de busqueda por rango esta habilitado
      |> assign_new(:button_range_enabled, fn -> true end)
      # estado para manejar el tipo de input para el filtro de rango/busqueda
      |> assign_new(:type_input, fn -> "text" end)
      # estado para manejar el valor de busqueda por rango
      |> assign_new(:values_search_range, fn -> [] end)
      # estado para manejar los datos de las columnas
      |> assign(
        :column_data,
        if socket.assigns[:column_data_loaded] do
          if socket.assigns.search_enabled || socket.assigns.range_enabled do
            assigns[:column_data]
          else
            (socket.assigns[:column_data] || []) ++ fixed_filters |> Enum.uniq()
          end
        else
          (assigns[:column_data] || []) ++ fixed_filters |> Enum.uniq()
        end
      )

    # Debug.print(socket.assigns[:column_data], label: "Socket assigns")

    {:ok, assign(socket, :column_data_loaded, true)}
  end

  def render(assigns) do
    ~H"""
    <div
      id={@column}
      phx-hook="TableTrackFilterContentPosition"
      class="table-track-filter-content-position"
    >
      <button
        class={"table-dropdown-toggle-#{@column}"}
        phx-click="toggle_filter_dropdown"
        phx-target={@myself}
        title="filtros"
      >
        <.icon
          name="hero-funnel-solid"
          class={
            if Enum.empty?(@selected_values) && Enum.empty?(@values_search_range),
              do: "bg-primary-mid-light hover:bg-primary",
              else: "bg-primary"
          }
          size="12px"
        />
      </button>
      <div
        :if={@show_filters}
        id="filter-dropdown"
        phx-hook="DisableDraggableColumns"
        class={[
          "table-dropdown-content-#{@column}",
          "flex flex-col fixed z-50 overflow-y-auto bg-white border border-gray-200 rounded-md w-fit max-h-[340px] p-2"
        ]}
        phx-click-away="close_filter_dropdown"
        phx-target={@myself}
      >
        <%= if @search_enabled do %>
          <.form
            for={@form}
            id="value_search"
            phx-target={@myself}
            phx-change="filter_search"
            autocomplete="off"
          >
            <div class="min-w-[130px] max-w-full h-min p-1 flex flex-col gap-y-1 border-b border-[#ccc]">
              <p class="text-xs font-bold">Busca valor:</p>
              <.input
                autofocus
                type="text"
                placeholder="Ingresar valor"
                phx-debounce="500"
                phx-update="ignore"
                field={@form[:search]}
              />
              <input type="hidden" name="column" value={@column} />
            </div>
            <%!-- <div class="min-w-[130px] max-w-full h-min p-1 flex flex-col gap-y-1 border-b border-[#ccc]">
              <p class="text-xs font-bold">Busca valor:</p>
              <.input
                autofocus
                type="money"
                placeholder="Ingresar valor"
                field={@form[:money]}
              />
              <input type="hidden" name="column" value={@column} />
            </div> --%>
          </.form>
        <% end %>
        <%= if @values_search_range > 0 do %>
          <%= for value <- @values_search_range do %>
            <div class="border-b border-secondary">
              <p class="text-xs font-bold">Busqueda de rango:</p>
              <p class="text-center"><%= value %></p>
              <.button
                type="button"
                phx-click="clean_range_filters"
                phx-target={@myself}
                phx-value-column={@column}
                phx-value-remove={value}
                class="w-full !py-0"
              >
                Eliminar rango
              </.button>
            </div>
          <% end %>
        <% end %>
        <%= if @range_enabled do %>
          <.form
            for={@form_range}
            id="values_search_range"
            phx-target={@myself}
            phx-submit="filter_search_by_range"
            autocomplete="off"
          >
            <div class="min-w-[130px] max-w-full h-max p-1 flex flex-col gap-y-1 border-b border-[#ccc]">
              <div :if={@button_range_enabled}>
                <p class="text-xs font-bold">Busca por rango desde:</p>
                <.input
                  autofocus
                  type={@type_input}
                  placeholder="Ingresar valor minimo"
                  field={@form_range[:range_min]}
                />
                <.print_error errors={@errors["range_min"]} />
                <p class="text-xs font-bold">Hasta:</p>
                <.input
                  autofocus
                  type={@type_input}
                  placeholder="Ingresar valor maximo"
                  field={@form_range[:range_max]}
                />
                <.print_error errors={@errors["range_max"]} />
                <input type="hidden" name="column" value={@column} />
                <.button :if={@button_range_enabled} type="submit" class="w-full !py-0">
                  Buscar
                </.button>
              </div>
            </div>
          </.form>
        <% end %>
        <div class="py-2 border-b border-[#ccc]">
          <.button
            id="clean_filters_button"
            phx-click="clean_filters"
            phx-value-column={@column}
            phx-target={@myself}
            title="Eliminar todos los filtros"
            class="w-full !py-0"
            disabled={Enum.empty?(@selected_values)}
          >
            Limpiar filtros()
          </.button>
        </div>

        <%= if @loading do %>
          <.spinner message="Cargando" />
        <% else %>
          <%= if Enum.empty?(@column_data || []) do %>
            <div class="py-2 text-gray-500">
              No hay datos
            </div>
          <% else %>
            <%= for value <- @column_data do %>
              <div class="flex items-center gap-x-2">
                <label class="flex items-center gap-x-2">
                  <.input
                    type="checkbox"
                    name="filter_value"
                    phx-click="filter"
                    phx-value-column={@column}
                    phx-value-data={
                      case value do
                        true -> "true"
                        false -> "false"
                        _ -> value
                      end
                    }
                    phx-target={@myself}
                    checked={to_string(value) in @selected_values}
                  />
                  <span>
                    <%= if value in [nil, ""], do: "Sin dato", else: value %>
                  </span>
                </label>
              </div>
            <% end %>
          <% end %>
        <% end %>
      </div>
    </div>
    """
  end

  # -----------------------
  # HANDLE EVENTS
  # -----------------------

  # Evento para manejar el filtrado de la tabla que consiste en 2 acciones: agregar y eliminar

  def handle_event("filter", %{"column" => column, "data" => value}, socket) do
    selected_values = socket.assigns.selected_values

    {updated_values, action, value_to_remove} =
      if value in selected_values do
        {List.delete(selected_values, value), :remove, value}
      else
        {[value | selected_values], :add, nil}
      end

    send(
      self(),
      {:filter_table,
       %{column: column, values: updated_values, action: action, value_to_remove: value_to_remove}}
    )

    {:noreply, assign(socket, :selected_values, updated_values)}
  end

  def handle_event("filter", %{"column" => column}, socket) do
    selected_values = socket.assigns.selected_values

    {updated_values, action, value_to_remove} =
      if "" in selected_values do
        {List.delete(selected_values, ""), :remove, ""}
      else
        {["" | selected_values], :add, nil}
      end

    send(
      self(),
      {:filter_table,
       %{column: column, values: updated_values, action: action, value_to_remove: value_to_remove}}
    )

    Debug.print(updated_values, label: "Updated values")
    {:noreply, assign(socket, :selected_values, updated_values)}
  end

  # Evento para manejar la busqueda en una columna
  def handle_event("filter_search", %{"search" => value, "column" => column}, socket) do
    send(self(), {:filter_search, %{value_search: value, column: column}})
    {:noreply, assign(socket, :loading, true)}
  end

  # Evento para manejar la busqueda por rango en una columna
  def handle_event(
        "filter_search_by_range",
        %{
          "range_search_utils" => %{"range_min" => range_min, "range_max" => range_max},
          "column" => column
        },
        socket
      ) do
    type_input = socket.assigns.type_input
    values_search_range = socket.assigns.values_search_range

    # Validar que los valores no sean nulos o vacíos
    errors = %{}

    errors =
      if range_min in [nil, ""] do
        Map.put(errors, "range_min", ["El valor no puede estar vacío"])
      else
        errors
      end

    errors =
      if range_max in [nil, ""] do
        Map.put(errors, "range_max", ["El valor no puede estar vacío"])
      else
        errors
      end

    if errors != %{} do
      socket =
        socket
        |> assign(:errors, errors)

      {:noreply, socket}
    else
      {range_min, range_max} =
        case type_input do
          "number" ->
            {String.to_integer(range_min), String.to_integer(range_max)}

          "date" ->
            {Date.from_iso8601!(range_min), Date.from_iso8601!(range_max)}

          "time" ->
            Debug.print(range_min, label: "Range min")
            Debug.print(range_max, label: "Range max")
            {parse_time(range_min), parse_time(range_max)}

          _ ->
            {range_min, range_max}
        end

      params = %{"range_min" => range_min, "range_max" => range_max}

      changeset =
        %RangeSearchUtils{}
        |> RangeSearchUtils.changeset(params)

      socket = UIHelpers.assign_form(socket, changeset, :form_range)

      if changeset.valid? do
        values_search_range =
          if Enum.member?(
               values_search_range,
               "#{to_string(range_min)} - #{to_string(range_max)}"
             ) do
            values_search_range
          else
            Enum.concat(values_search_range, ["#{to_string(range_min)}/#{to_string(range_max)}"])
          end

        send(
          self(),
          {:filter_search_by_range, %{values_search_range: values_search_range, column: column}}
        )

        changeset = RangeSearchUtils.changeset(%RangeSearchUtils{})

        socket =
          socket
          |> assign(:errors, %{})
          |> assign(:values_search_range, values_search_range)
          |> UIHelpers.assign_form(changeset, :form_range)
          |> UIHelpers.assign_form(%{})

        {:noreply, socket}
      else
        errors =
          changeset
          |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
            Enum.reduce(opts, msg, fn {key, value}, acc ->
              String.replace(acc, "%{#{key}}", to_string(value))
            end)
          end)
          |> Enum.map(fn {field, messages} ->
            {Atom.to_string(field), messages}
          end)
          |> Enum.into(%{})

        Debug.print(errors, label: "Errors")

        socket =
          socket
          |> assign(:errors, errors)

        {:noreply, socket}
      end
    end
  end

  # Evento para manejar la apertura del dropdown de filtros
  def handle_event("toggle_filter_dropdown", _params, socket) do
    {:noreply, assign(socket, :show_filters, true)}
  end

  # Evento para manejar el cierre del dropdown de filtros
  def handle_event("close_filter_dropdown", _params, socket) do
    {:noreply, assign(socket, :show_filters, false)}
  end

  # Evento para manejar la limpieza de los filtros aplicados en una columna, limpiar(vacia los filtros/rangos aplicados de una columna)
  def handle_event("clean_filters", %{"column" => column}, socket) do
    selected_values = socket.assigns.selected_values

    send(
      self(),
      {:filter_table,
       %{column: column, values: selected_values, action: :clean, value_to_remove: nil}}
    )

    socket =
      socket
      |> assign(:selected_values, [])
      |> assign(:values_search_range, [])

    {:noreply, socket}
  end

  # Evento para manejar la limpieza rangos aplicados en una columna, limpiar(vacia los rangos aplicados de una columna)
  def handle_event("clean_range_filters", %{"column" => column, "remove" => remove}, socket) do
    values_search_range = socket.assigns.values_search_range

    values_search_range =
      Enum.reject(values_search_range, fn valor -> valor == remove end)

    send(
      self(),
      {:delete_range_filters,
       %{column: column, remove: remove, values_search_range: values_search_range}}
    )

    changeset = RangeSearchUtils.changeset(%RangeSearchUtils{})

    socket =
      socket
      |> assign(:values_search_range, values_search_range)

    {:noreply,
     socket
     |> UIHelpers.assign_form(changeset, :form_range)
     |> UIHelpers.assign_form(%{})}
  end

  #
  def handle_info({:filter_search, _params}, socket) do
    {:noreply, assign(socket, :loading, false)}
  end

  defp parse_time(time_string) do
    case Time.from_iso8601(time_string) do
      {:ok, time} ->
        time

      {:error, _reason} ->
        if String.length(time_string) == 8 do
          Time.from_iso8601!(time_string)
        else
          Time.from_iso8601!(time_string <> ":00")
        end
    end
  end
end
