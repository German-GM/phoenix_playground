#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-2/lib/tunez/music.ex

# ------------------------------------------------------------------------------
# Context: Adding code interface functions for actions in the Album resource
resources do
  # ...
  resource Tunez.Music.Album do
    define :create_album, action: :create
    define :get_album_by_id, action: :read, get_by: :id
    define :update_album, action: :update
    define :destroy_album, action: :destroy
  end
end
# ------------------------------------------------------------------------------
