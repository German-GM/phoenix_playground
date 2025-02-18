#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-8/mix.exs

# ------------------------------------------------------------------------------
# Context: Uncommenting the last seed file so that `mix seed` can
# import Artist, Album and Track data into the database
defp aliases do
  [
    setup: ["deps.get", "ash.setup", "assets.setup", "assets.build", ...],
    "ecto.setup": ["ecto.create", "ecto.migrate"],
    seed: [
      "run priv/repo/seeds/01-artists.exs",
      "run priv/repo/seeds/02-albums.exs",
      "run priv/repo/seeds/08-tracks.exs"
    ],
    # ...
# ------------------------------------------------------------------------------
