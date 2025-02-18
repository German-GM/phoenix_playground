#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-1/lib/tunez_web/live/artists/show_live.ex

# ------------------------------------------------------------------------------
# Context: The hardcoded sample artist data on the artist profile page
def handle_params(_params, _url, socket) do
  artist = %{
    id: "test-artist-1",
    name: "Artist Name",
    biography: some sample biography content
  }
  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Replacing the sample artist data with data from the database
def handle_params(%{"id" => artist_id}, _url, socket) do
  artist = Tunez.Music.get_artist_by_id!(artist_id)
  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The Delete Artist button, with the click event it issuse
<.button_link kind="error" text phx-click="destroy_artist"
  data-confirm={"Are you sure you want to delete #{@artist.name}?"}>
  Delete Artist
</.button_link>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: After implementing the code to delete a given artist record
def handle_event("destroy_artist", _params, socket) do
  case Tunez.Music.destroy_artist(socket.assigns.artist) do
    :ok ->
      socket =
        socket
        |> put_flash(:info, "Artist deleted successfully")
        |> push_navigate(to: ~p"/")

      {:noreply, socket}

    {:error, error} ->
      Logger.info("Could not delete artist '#{socket.assigns.artist.id}':
        #{inspect(error)}")

      socket =
        socket
        |> put_flash(:error, "Could not delete artist")

      {:noreply, socket}
  end
end
# ------------------------------------------------------------------------------
