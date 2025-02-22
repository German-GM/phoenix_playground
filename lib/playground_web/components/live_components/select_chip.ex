defmodule LynxwebWeb.LiveComponents.SelectChip do
  use LynxwebWeb, :live_component

  def mount(socket) do
    {:ok,
     assign(socket,
       selected_options: [],
       options: ["Option 1", "Option 2", "Option 3"],
       field: "",
       index: nil,
       single_selection: false
     )}
  end

  def handle_event("select_option", params, socket) do
    value = Map.get(params, "value")
    data = Map.get(params, "data", nil)

    selected_options = socket.assigns.selected_options

    updated_options =
      if socket.assigns.single_selection do
        if value != nil, do: [value], else: []
      else
        if data do
          List.delete(selected_options, data)
        else
          if value not in selected_options,
            do: Enum.uniq([value | selected_options]),
            else: selected_options
        end
      end

    send(
      self(),
      {:update_selected_options, socket.assigns.index, updated_options, socket.assigns.field}
    )

    {:noreply, assign(socket, selected_options: updated_options)}
  end

  def render(assigns) do
    ~H"""
    <div class="w-full max-w-md mx-auto mt-5">
      <label class="block text-sm font-medium text-gray-700 mb-1">
        <%= if !@single_selection do %>
          Selecciona opciones
        <% else %>
          Selecciona una opción
        <% end %>
      </label>
      <div id={"selecte_options_#{System.unique_integer()}"} class="flex flex-wrap mb-2">
        <%= for option <- @selected_options do %>
          <div class="flex items-center bg-blue-100 text-blue-800 text-sm font-medium mr-2 mb-2 px-2.5 py-0.5 rounded">
            <%= option %>
            <button
              :if={!@single_selection}
              phx-target={@myself}
              phx-click="select_option"
              phx-value-data={option}
              class="ml-1 text-blue-600 hover:text-blue-800 focus:outline-none"
            >
              <.icon name="hero-x-mark" size="14px" />
            </button>
          </div>
        <% end %>
      </div>
      <select
        multiple
        class="block w-full border border-gray-300 rounded-md shadow-md focus:outline-none focus:ring-2 focus:ring-blue-500 bg-white p-2"
        phx-target={@myself}
        phx-click="select_option"
      >
        <%= for option <- @options do %>
          <option value={option}><%= option %></option>
        <% end %>
      </select>
    </div>
    """
  end
end
