defmodule LynxwebWeb.LiveComponents.PaginationComponent do
  use LynxwebWeb, :live_component

  alias LynxwebWeb.LiveComponents.PaginationForm

  def render(assigns) do
    ~H"""
    <div class="flex flex-col items-center space-y-4">
      <div class="flex space-x-2">
        <%= for {page_number, current_page?} <- pages(@pagination) do %>
          <div
            phx-click="show_page"
            phx-value-page={page_number}
            phx-target={@myself}
            class={"cursor-pointer px-4 py-2 border rounded " <>
               (if current_page?, do: "bg-blue-500 text-white", else: "bg-white text-blue-500 hover:bg-blue-100")}
          >
            <%= page_number %>
          </div>
        <% end %>
      </div>

      <div class="flex flex-col items-center space-y-2">
        <.form
          for={%{}}
          as={:page_size}
          phx-change="set_page_size"
          phx-target={@myself}
          class="w-full max-w-xs"
        >
          <.input
            id="page_size"
            name="page_size"
            type="select"
            options={[{"10", 10}, {"20", 20}, {"50", 50}]}
            value={@pagination.page_size}
          />
        </.form>

        <div class="text-sm text-gray-600">
          <%= @pagination.total_count %> registros
        </div>
      </div>
    </div>
    """
  end

  def pages(%{page_size: page_size, page: current_page, total_count: total_count}) do
    page_count = ceil(total_count / page_size)

    for page_number <- 1..page_count//1 do
      current_page? = page_number == current_page
      {page_number, current_page?}
    end
  end

  def handle_event("show_page", params, socket) do
    parse_params(params, socket)
  end

  def handle_event("set_page_size", %{"page_size" => params}, socket) do
    params = %{"page_size" => params}
    parse_params(params, socket)
  end

  defp parse_params(params, socket) do
    %{pagination: pagination} = socket.assigns

    case PaginationForm.parse(params, pagination) do
      {:ok, opts} ->
        send(self(), {:update, opts})
        {:noreply, socket}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
