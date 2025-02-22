defmodule LynxwebWeb.LiveComponents.AutocompleteInput do
  use LynxwebWeb, :custom_live_component

  alias Lynxweb.Utilities.Agnostic
  alias Agnostic.{UIHelpers}

  @doc """
  Regresa una caja de búsqueda con autocompletado.

  ## Ejemplo

      <.autocomplete_input
        id="autocomplete"
        placeholder="Buscar ID de tarjeta..."
        maxlength="36"
        search_data_callback={fn _search -> [%{id: "11", masked_pan: "1"}, %{id: "12", masked_pan: "2"}] end}
        selected_item_callback={fn selected -> selected end}
      />
  """
  attr :id, :string, required: true
  attr :placeholder, :string, default: "Buscar..."
  attr :maxlength, :string, default: nil
  attr :clear_on_selected, :boolean, default: false
  attr :search_data_callback, :any, required: true, doc: "Function that returns the data of the searched term. Example: fn search -> get_data(search) end"
  attr :selected_item_callback, :any, required: true, doc: "Function that returns the selected item. Example: fn selected -> callback(selected) end"
  attr :rest, :global

  # El nombre de la función debe nombrarse igual que el nombre del módulo pero en formato snake_case
  # Ejemplo: "LynxwebWeb.LiveComponents.ModuloComponente", función: "modulo_componente(assigns)", html: <.modulo_componente />
  def autocomplete_input(assigns) do
    ~H"""
    <.live_component module={__MODULE__} {assigns_to_attributes(assigns)} />
    """
  end

  def mount(socket) do
    socket =
      socket
      |> assign(
        search_results: [],
        search: "",
        current_focus: -1,
        show_no_results_msg: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <form
      id={@id}
      phx-hook="AutocompletePosition"
      phx-change="search"
      phx-submit="submit"
      autocomplete="off"
      phx-target={@myself}
      class="w-full relative"
    >
      <div phx-click-away="close-suggestion-box" phx-target={@myself}>
        <.input
          id={"autocomplete-#{@id}"}
          type="text"
          class="form-control"
          name="autocomplete-search"
          value={@search}
          phx-debounce="1000"
          placeholder={@placeholder}
          maxlength={@maxlength}
          phx-target={@myself}
          {@rest}
        />

        <div
          id={"autocomplete-#{@id}-results"}
          class={[
            "absolute z-50 w-fit min-w-full max-h-64 overflow-auto whitespace-nowrap",
            "rounded border border-gray-100 shadow  bg-white",
            "#{if length(@search_results) == 0, do: "hidden"}"
          ]}
          phx-window-keydown="set-focus"
          phx-target={@myself}
        >
          <div
            :for={{search_result, idx} <- Enum.with_index(@search_results)}
            class={[
              "cursor-pointer py-3 pl-3 pr-4 hover:bg-gray-200 focus:bg-gray-200 even:bg-primary-subtle-light",
              "#{if idx == @current_focus, do: "!bg-gray-200"}"
            ]}
            phx-click="on-selected"
            phx-value-id={search_result.id}
            phx-target={@myself}
          >
            <%= raw format_search_result(search_result.id, @search) %>
          </div>
        </div>

        <%= if @show_no_results_msg do %>
          <div class="relative z-50">
            <div class="absolute w-fit whitespace-nowrap rounded border border-gray-100 shadow bg-white">
              <div class="py-2 px-4">
                No hay resultados
              </div>
            </div>
          </div>
        <% end %>
      </div>
    </form>
    """
  end

  def handle_event("search", %{"autocomplete-search" => search}, socket) do
    search = String.trim(search)
    data_source = socket.assigns.search_data_callback.(search)
    search_results = search |> filter_search(data_source)

    socket = socket
    |> assign(
      search_results: search_results,
      search: search,
      current_focus: -1,
      show_no_results_msg: search != "" && search_results == []
    )

    {:noreply, socket}
  end

  def handle_event("on-selected", %{"id" => selected}, socket) do
    clear_on_selected = socket.assigns.clear_on_selected

    search_results = socket.assigns.search_results
    item_selected = Enum.find(search_results, fn item ->
      if is_map(item) do
        item.id == selected
      else
        item == selected
      end
    end)

    socket = socket
    |> focus_autocomplete_input(clear_on_selected)
    |> assign(
      search_results: [],
      search: (if clear_on_selected, do: "", else: selected)
    )

    socket.assigns.selected_item_callback.(item_selected)
    {:noreply, socket}
  end

  def handle_event("on-selected", _, socket), do: {:noreply, socket}

  def handle_event("set-focus", %{"key" => "Enter"}, socket) do
    search_results = socket.assigns.search_results
    current_focus = socket.assigns.current_focus
    selected = Enum.at(search_results, current_focus)

    case selected do
      selected when is_map(selected) ->
        handle_event("on-selected", %{"id" => selected.id}, socket)

      selected when is_binary(selected) ->
        handle_event("on-selected", %{"id" => selected}, socket)

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("set-focus", %{"key" => "ArrowUp"}, socket) do
    current_focus =
      Enum.max([(socket.assigns.current_focus - 1), 0])

    {:noreply, assign(socket, current_focus: current_focus)}
  end

  def handle_event("set-focus", %{"key" => "ArrowDown"}, socket) do
    current_focus =
      Enum.min([(socket.assigns.current_focus + 1), (length(socket.assigns.search_results) - 1)])
    {:noreply, assign(socket, current_focus: current_focus)}
  end

  def handle_event("set-focus", _, socket), do: {:noreply, socket}

  def handle_event("submit", _, socket), do: {:noreply, socket}

  def handle_event("close-suggestion-box", _, socket) do
    {:noreply, assign(socket, search_results: [], show_no_results_msg: false)}
  end

  defp format_search_result(search_result, search) do
    case Agnostic.split_string_by_substring(search_result, search) do
      {:ok, {prefix, middle, suffix}} ->
        "#{prefix}<strong>#{middle}</strong>#{suffix}"

      _ ->
        search_result
    end
  end

  # Normaliza la fuente de datos a una lista de mapas con la clave :id, si el contenido de la lista son strings
  defp normalize_data_source(data_source) do
    Enum.map(data_source, fn data ->
      if is_binary(data), do: %{id: data}, else: data
    end)
  end

  defp filter_search("", _data_source), do: []

  defp filter_search(search, data_source) do
    data_source
    |> normalize_data_source()
    |> Enum.filter(&matches?(&1, search))
  end

  defp matches?(data_source, contents) do
    String.contains?(
      String.downcase(data_source.id), String.downcase(contents)
    )
  end

  defp focus_autocomplete_input(socket, condition) do
    if condition do
      UIHelpers.focus_input(socket, "autocomplete-#{socket.assigns.id}")
    else
      socket
    end
  end
end
