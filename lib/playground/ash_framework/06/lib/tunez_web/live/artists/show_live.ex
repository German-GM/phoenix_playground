#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-6/lib/tunez_web/live/artists/show_live.ex

# ------------------------------------------------------------------------------
# Context: Adding authorization to the `get_artist_by_id` function call
def handle_params(%{"id" => artist_id}, _session, socket) do
  artist =
    Tunez.Music.get_artist_by_id!(artist_id,
      load: [:albums],
      actor: socket.assigns.current_user
    )
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding authorization to the `destroy_artist` function call
def handle_event("destroy_artist", _params, socket) do
  case Tunez.Music.destroy_artist(
    socket.assigns.artist,
    actor: socket.assigns.current_user
  ) do
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding authorization to the `destroy_album` function call
def handle_event("destroy_album", %{"id" => album_id}, socket) do
  case Tunez.Music.destroy_album(
    album_id,
    actor: socket.assigns.current_user
  ) do
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding authorization around the "Delete Artist" button
<.header>
  <% # ... %>
  <:action :if={Tunez.Music.can_destroy_artist?(@current_user, @artist)}>
    <.button_link [opts]>Delete Artist</.button_link>
  </:action>
  <:action :if={Tunez.Music.can_update_artist?(@current_user, @artist)}>
    <.button_link [opts]>Edit Artist</.button_link>
  </:action>
</.header>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding authorization around the "New Album" button
<.button_link navigate={~p"/artists/#{@artist.id}/albums/new"} kind="primary"
  :if={Tunez.Music.can_create_album?(@current_user)}>
  New Album
</.button_link>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding authorization to the "Edit Album" and "Delete Album" buttons
<.header class="pl-4 pr-2 !m-0">
  <% # ... %>
  <:action :if={Tunez.Music.can_destroy_album?(@current_user, @album)}>
    <.button_link [opts]]>Delete</.button_link>
  </:action>
  <:action :if={Tunez.Music.can_update_album?(@current_user, @album)}>
    <.button_link [opts]>Edit</.button_link>
  </:action>
</.header>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Passing the current user to the `album_details` function component
# so it can be used in authorization within it
<ul class="mt-10 space-y-6 md:space-y-10">
  <li :for={album <- @artist.albums}>
    <.album_details album={album} current_user={@current_user} />
  </li>
</ul>
# ------------------------------------------------------------------------------
