defmodule LynxwebWeb.LiveComponents.PaginationArrowComponent do
  use LynxwebWeb, :live_component
  alias LynxwebWeb.LiveComponents.PaginationForm

  def render(assigns) do
    ~H"""
    <div class="flex items-center justify-between border-t border-gray-200 px-4 pt-3 sm:px-6">
      <div class="hidden sm:block">
        <%!-- current_page: 1, results_per_page: 40, total_pages: 1, total_results: 5 --%>
        <p class="text-sm text-gray-700">
          Mostrando página <span class="font-medium"><%= @pagination.page %></span>
          de
          <span class="font-medium">
            <%= ceil(@pagination.total_count / @pagination.page_size) %>
          </span>
        </p>
        <div class="text-sm text-gray-600">
          <%= @pagination.total_count %> registros
        </div>
      </div>
      <div class="flex flex-1 justify-between sm:justify-end space-x-3">
        <.button
          color="default"
          phx-click="on-page-change"
          phx-target={@myself}
          phx-value-page={@pagination.page - 1}
          disabled={@loading || @pagination.page == 1}
        >
          Anterior
        </.button>
        <.button
          color="default"
          phx-click="on-page-change"
          phx-target={@myself}
          phx-value-page={@pagination.page + 1}
          disabled={
            @loading || @pagination.page == ceil(@pagination.total_count / @pagination.page_size)
          }
        >
          Siguiente
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("on-page-change", %{"page" => _page} = params, socket) do
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
