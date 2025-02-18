#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-1/lib/tunez_web/live/artists/form_live.ex

# ------------------------------------------------------------------------------
# Context: Replacing the static generated form with an AshPhoenix.Form
def mount(_params, _session, socket) do
  form = Tunez.Music.form_to_create_artist()

  socket =
    socket
    |> assign(:form, to_form(form))
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The validation event handler before we make it work
def handle_event("validate", %{"form" => _form_data}, socket) do
  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The validation event handler after we make it work
def handle_event("validate", %{"form" => form_data}, socket) do
  socket =
    update(socket, :form, fn form ->
      AshPhoenix.Form.validate(form, form_data)
    end)

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The save event handler after we make it work
def handle_event("save", %{"form" => form_data}, socket) do
  case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
    {:ok, _artist} ->
      socket =
        socket
        |> put_flash(:info, "Artist saved successfully")
        |> push_navigate(to: ~p"/")

      {:noreply, socket}

    {:error, form} ->
      socket =
        socket
        |> put_flash(:error, "Could not save artist data")
        |> assign(:form, form)

      {:noreply, socket}
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a second function head so that the form works for both create and update
def mount(%{"id" => artist_id}, _session, socket) do
  artist = Tunez.Music.get_artist_by_id!(artist_id)
  form = Tunez.Music.form_to_update_artist(artist)

  socket =
    socket
    |> assign(:form, to_form(form))
    |> assign(:page_title, "Update Artist")

  {:ok, socket}
end

def mount(_params, _session, socket) do
  form = Tunez.Music.form_to_create_artist()
  # ...
# ------------------------------------------------------------------------------
