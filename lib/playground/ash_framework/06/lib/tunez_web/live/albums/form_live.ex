#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-6/lib/tunez_web/live/albums/form_live.ex

# ------------------------------------------------------------------------------
# Context: Passing in the actor when reading an album by ID
def mount(%{"id" => album_id}, _session, socket) do
  album = Tunez.Music.get_album_by_id!(album_id,
    load: [:artist],
    actor: socket.assigns.current_user
  )

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Passing in the actor when reading an artist by ID
def mount(%{"artist_id" => artist_id}, _session, socket) do
  artist = Tunez.Music.get_artist_by_id!(artist_id,
    actor: socket.assigns.current_user
  )

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Updating the Album form to ensure the authenticated user is authorized to submit it
def mount(%{"id" => album_id}, _session, socket) do
  # ...

  form =
    Tunez.Music.form_to_update_album(
      album,
      actor: socket.assigns.current_user
    )
    |> AshPhoenix.Form.ensure_can_submit!()

  # ...

def mount(%{"artist_id" => artist_id}, _session, socket) do
  # ...

  form =
    Tunez.Music.form_to_create_album(
      transform_params: fn _form, params, _context ->
        Map.put(params, "artist_id", artist.id)
      end,
      actor: socket.assigns.current_user
    )
    |> AshPhoenix.Form.ensure_can_submit!()
# ------------------------------------------------------------------------------
