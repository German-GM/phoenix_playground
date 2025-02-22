defmodule LynxwebWeb.LiveComponents.FilterQuerys do
  use LynxwebWeb, :live_component
  alias Lynxweb.Utilities.Agnostic.FilterFormatter

  def update(assigns, socket) do
    # Ensure filter_querys is transformed and assigned properly
    filter_querys =
      assigns.filter_querys
      |> Enum.map(fn {k, v} ->
        {k, Enum.map(v, fn value -> if value == "", do: "Sin dato", else: value end)}
      end)
      |> Enum.into(%{})

    socket =
      socket
      |> assign(assigns)
      |> assign(:filter_querys, filter_querys)

    Debug.print(socket.assigns.filter_querys, label: "filter_querys in FilterQuerys")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="flex items-center pt-5 text-gray-700">
      <%= if map_size(@filter_querys) > 0  or map_size(@params) > 0 do %>
        <.button
          :if={map_size(@filter_querys) > 0}
          phx-click="delete_filters"
          class="!w-min !h-min !p-2 !mr-2 !flex !items-center !justify-center"
        >
          <.icon name="hero-x-mark" size="16px" />
        </.button>
        <span class="font-medium">Filtrando por: </span>
        <span class="text-sm ml-2">
          <%= FilterFormatter.format_filter_querys(
            @filter_querys,
            assigns.priority_columns,
            assigns.params
          ) %>
        </span>
      <% end %>
    </div>
    """
  end

  # Evento para borrar todos los filtros
  def handle_event("delete_filters", _params, socket) do
    push_event(socket, "delete_filters", %{})
    {:noreply, assign(socket, filter_querys: %{})}
  end
end
