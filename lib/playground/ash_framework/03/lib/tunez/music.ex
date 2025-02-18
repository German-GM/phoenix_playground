#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-3/lib/tunez/music.ex

# ------------------------------------------------------------------------------
# Context: Adding a code interface function for the new Artist `search` action
resource Tunez.Music.Artist do
  # ...
  define :search_artists, action: :search, args: [:query]
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading the aggregates by default with every call to the `search_artists` code interface
define :search_artists,
        action: :search,
        args: [:query],
        default_options: [
          load: [:album_count, :latest_album_year_released, :cover_image_url]
        ]
# ------------------------------------------------------------------------------
