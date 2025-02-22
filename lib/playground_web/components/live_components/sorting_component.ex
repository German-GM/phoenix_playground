defmodule LynxwebWeb.LiveComponents.SortingComponent do
  use LynxwebWeb, :live_component

  def update(assigns, socket) do
    socket =
      socket
      |> assign(cadena: true)
      |> assign(assigns)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div phx-click="sort" phx-target={@myself} class="whitespace-nowrap cursor-pointer">
      <%= @label %>
      <.chevron
        key={@key}
        sort_by={@sorting.sort_by}
        sort_dir={@sorting.sort_dir}
        column={if assigns.cadena, do: assigns.key, else: Atom.to_string(assigns.key)}
      />
    </div>
    """
  end

  def handle_event("sort", _params, socket) do
    %{sorting: %{sort_dir: sort_dir}, key: key} = socket.assigns

    sort_dir = if sort_dir == :asc, do: :desc, else: :asc
    opts = %{sort_by: key, sort_dir: sort_dir}

    send(self(), {:update, opts})
    {:noreply, assign(socket, sorting: opts)}
  end

  defp chevron(assigns) do
    ~H"""
    <span :if={assigns.sort_by == assigns.column}>
      <.icon
        name={if assigns.sort_dir == :asc, do: "hero-chevron-up", else: "hero-chevron-down"}
        size="14px"
      />
    </span>
    """
  end
end
