#---
# Excerpted from "Building Table Views with Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/puphoe for more book information.
#---
defmodule MeowWeb.MeerkatLive.SortingComponent do
  use MeowWeb, :live_component

  def render(assigns) do
    ~H"""
    <div phx-click="sort_by_key" phx-target={@myself} class="sorting-header" >
      <%= @key %> <%= chevron(@sorting, @key) %>
    </div>
    """
  end

  def handle_event("sort_by_key", _params, socket) do
    %{sorting: %{sort_dir: sort_dir}, key: key} = socket.assigns

    sort_dir = if sort_dir == :asc, do: :desc, else: :asc
    opts = %{sort_by: key, sort_dir: sort_dir}

    send(self(), {:update, opts})
    {:noreply, socket}
  end

  def chevron(%{sort_by: sort_by, sort_dir: sort_dir}, key) when sort_by == key do
    if sort_dir == :asc, do: "⇧", else: "⇩"
  end

  def chevron(_opts, _key), do: ""
end
