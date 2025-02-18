#---
# Excerpted from "Building Table Views with Phoenix LiveView",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/puphoe for more book information.
#---
defmodule MeowWeb.InfinityLive do
  use MeowWeb, :live_view

  alias Meow.Meerkats

  def render(assigns) do
    ~H"""
    <table>
      <div id="ping-div" phx-hook="PingPongHook" />
      <tbody id="meerkats"
             phx-update="append"
             phx-hook="InfinityScroll">
        <%= for meerkat <- @meerkats do %>
          <tr id={"meerkat-#{meerkat.id}"}>
            <td><%= meerkat.id %></td>
            <td><%= meerkat.name %></td>
          </tr>
        <% end %>
      </tbody>
    </table>
    """
  end

  def mount(_params, _session, socket) do
    count = Meerkats.meerkat_count()

    socket =
      socket
      |> assign(offset: 0, limit: 25, count: count)
      |> load_meerkats()

    {:ok, socket, temporary_assigns: [meerkats: []]}
  end

  def handle_event("ping", params, socket) do
    IO.inspect("ping", label: "Event")
    IO.inspect(params, label: "Params")
    {:noreply, push_event(socket, "pong", %{message: "Hello there!"})}
  end

  def handle_event("load-more", _params, socket) do
    %{offset: offset, limit: limit, count: count} = socket.assigns

    socket =
      if offset < count do
        socket
        |> assign(offset: offset + limit)
        |> load_meerkats()
      else
        socket
      end

    {:noreply, socket}
  end

  defp load_meerkats(%{assigns: %{offset: offset, limit: limit}} = socket) do
    meerkats = Meerkats.list_meerkats_with_pagination(offset, limit)
    assign(socket, :meerkats, meerkats)
  end
end
