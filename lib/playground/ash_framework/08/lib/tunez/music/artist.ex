#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-8/lib/tunez/music/artist.ex

# ------------------------------------------------------------------------------
# Context: Allowing track data to be read over the JSON API when fetching artists
defmodule Tunez.Music.Artist do
  # ...

  json_api do
    type "artist"
    includes albums: [:tracks]
    derive_filter? false
  end
# ------------------------------------------------------------------------------
