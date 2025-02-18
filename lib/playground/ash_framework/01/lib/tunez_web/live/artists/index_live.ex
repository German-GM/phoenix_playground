#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-1/lib/tunez_web/live/artists/index_live.ex

# ------------------------------------------------------------------------------
# Context: The hardcoded sample artist data in the Artist catalog
def handle_params(_params, _url, socket) do
  artists = [
    %{id: "test-artist-1", name: "Test Artist 1"},
    %{id: "test-artist-2", name: "Test Artist 2"},
    %{id: "test-artist-3", name: "Test Artist 3"},
  ]

  socket =
    socket
    |> assign(:artists, artists)

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: How the artist data is rendered within the HEEX template
<li :for={artist <- @artists}>
  <.artist_card artist={artist} />
</li>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Replacing the hardcoded artist data with data from the database
def handle_params(_params, _url, socket) do
  artists = Tunez.Music.read_artists!()
  # ...
# ------------------------------------------------------------------------------
