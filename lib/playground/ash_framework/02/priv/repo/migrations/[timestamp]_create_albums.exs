#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-2/priv/repo/migrations/20250101123316_create_albums.exs

# ------------------------------------------------------------------------------
# Context: The generated migration after adding the relationship from albums -> artists
def up do
  create table(:albums, primary_key: false) do
    # ...
    add :artist_id,
        references(:artists,
          column: :id,
          name: "albums_artist_id_fkey",
          type: :uuid,
          prefix: "public"
        )
  end
end
# ------------------------------------------------------------------------------
