#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-2/lib/tunez_web/live/albums/form_live.ex

# ------------------------------------------------------------------------------
# Context: Replacing the static generated form with an AshPhoenix.Form
def mount(_params, _session, socket) do
  form = Tunez.Music.form_to_create_album()

  socket =
    socket
    |> assign(:form, to_form(form))
    ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Implementing the logic to validate form data on change
def handle_event("validate", %{"form" => form_data}, socket) do
  socket =
    update(socket, :form, fn form ->
      AshPhoenix.Form.validate(form, form_data)
    end)

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Implementing the logic to save form data on submit
def handle_event("save", %{"form" => form_data}, socket) do
  case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
    {:ok, album} ->
      socket =
        socket
        |> put_flash(:info, "Album saved successfully")
        |> push_navigate(to: ~p"/artists/#{album.artist_id}")

      {:noreply, socket}

    {:error, form} ->
      socket =
        socket
        |> put_flash(:error, "Could not save album data")
        |> assign(:form, form)

      {:noreply, socket}
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a second function head so that the form works for both create and update
def mount(%{"id" => album_id}, _session, socket) do
  album = Tunez.Music.get_album_by_id!(album_id)
  form = Tunez.Music.form_to_update_album(album)

  socket =
    socket
    |> assign(:form, to_form(form))
    |> assign(:page_title, "Update Album")

  {:ok, socket}
end

def mount(params, _session, socket) do
  form = Tunez.Music.form_to_create_album()
  ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading the selected artist record to show on the create form
def mount(%{"artist_id" => artist_id}, _session, socket) do
  artist = Tunez.Music.get_artist_by_id!(artist_id)
  form = Tunez.Music.form_to_create_album()

  socket =
    socket
    |> assign(:form, to_form(form))
    |> assign(:artist, artist)
    ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading the selected artist record to show on the update form
def mount(%{"id" => album_id}, _session, socket) do
  album = Tunez.Music.get_album_by_id!(album_id)
  artist = Tunez.Music.get_artist_by_id!(album.artist_id)
  form = Tunez.Music.form_to_update_album(album)

  socket =
    socket
    |> assign(:form, to_form(form))
    |> assign(:artist, artist)
    ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Showing the loaded artist details on the Album form
<.input name="artist_id" value={@artist.name} label="Artist" disabled />
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Securely submitting the loaded artist ID with the form data
def mount(%{"artist_id" => artist_id}, _session, socket) do
  artist = Tunez.Music.get_artist_by_id!(artist_id)

  form =
    Tunez.Music.form_to_create_album(
      transform_params: fn _form, params, _context ->
        Map.put(params, "artist_id", artist.id)
      end
    )
  ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using the `load` option to preload the artist for an album record
def mount(%{"id" => album_id}, _session, socket) do
  album = Tunez.Music.get_album_by_id!(album_id, load: [:artist])
  form = Tunez.Music.form_to_update_album(album)

  socket =
    socket
    |> assign(:form, to_form(form))
    |> assign(:artist, album.artist)
    ...
# ------------------------------------------------------------------------------
