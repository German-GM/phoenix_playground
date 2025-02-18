#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-2/lib/tunez_web/live/artists/show_live.ex

# ------------------------------------------------------------------------------
# Context: The hardcoded sample album data on the Artist profile page
def handle_params(%{"id" => artist_id}, _url, socket) do
  artist = Tunez.Music.get_artist_by_id!(artist_id)

  albums = [
    %{
      id: "test-album-1",
      name: "Test Album",
      year_released: 2023,
      cover_image_url: nil
    }
  ]

  socket =
    socket
    |> assign(:artist, artist)
    |> assign(:albums, albums)
    |> assign(:page_title, artist.name)

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Replacing the sample album data with data from the database
def handle_params(%{"id" => artist_id}, _url, socket) do
  artist = Tunez.Music.get_artist_by_id!(artist_id, load: [:albums])

  socket =
    socket
    |> assign(:artist, artist)
    |> assign(:page_title, artist.name)

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: How the sample album data is rendered
<li :for={album <- @albums}>
  <.album_details album={album} />
</li>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: How the real album data should be rendered, via the artist
<li :for={album <- @artist.albums}>
  <.album_details album={album} />
</li>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Implementing the logic for how to delete album records
def handle_event("destroy_album", %{"id" => album_id}, socket) do
  case Tunez.Music.destroy_album(album_id) do
    :ok ->
      socket =
        socket
        |> update(:artist, fn artist ->
          Map.update!(artist, :albums, fn albums ->
            Enum.reject(albums, &(&1.id == album_id))
          end)
        end)
        |> put_flash(:info, "Album deleted successfully")

      {:noreply, socket}

    {:error, error} ->
      Logger.info("Could not delete album '#{album_id}': #{inspect(error)}")

      socket =
        socket
        |> put_flash(:error, "Could not delete album")

      {:noreply, socket}
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: How to display an artist's previous names on their profile
<.header>
  <.h1>...</.h1>
  <:subtitle :if={@artist.previous_names != []}>
    formerly known as: {Enum.join(@artist.previous_names, ", ")}
  </:subtitle>
  ...
</.header>
# ------------------------------------------------------------------------------
