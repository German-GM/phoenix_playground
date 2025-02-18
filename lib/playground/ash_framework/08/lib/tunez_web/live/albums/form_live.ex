#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-8/lib/tunez_web/live/albums/form_live.ex

# ------------------------------------------------------------------------------
# Context: Adding forms for editing Tracks to the Album form
<% # ... %>

<.input field={form[:cover_image_url]} label="Cover Image URL" />

<.track_inputs form={form} />

<:actions>
  <% # ... %>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading tracks for albums to pre-populate on the album form
def mount(%{"id" => album_id}, _session, socket) do
  album =
    Tunez.Music.get_album_by_id!(album_id,
      load: [:artist, :tracks],
      actor: socket.assigns.current_user
    )

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Implementing the `add-track` event handler
def handle_event("add-track", _params, socket) do
  socket =
    update(socket, :form, fn form ->
      AshPhoenix.Form.add_form(form, :tracks)
    end)

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Auto-incrementing the `order` field when adding new tracks
def handle_event("add-track", _params, socket) do
  socket =
    update(socket, :form, fn form ->
      order = length(AshPhoenix.Form.value(form, :tracks)) + 1
      AshPhoenix.Form.add_form(form, :tracks, params: %{order: order})
    end)

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Showing the path being generated for each Delete Track button
<td class="align-top w-12 pt-5">
  <.button_link phx-click="remove-track" phx-value-path={track_form.name}
    kind="error" size="xs" text class="mt-0.5"
  >
    <.icon name="hero-trash" class="w-5 h-5" />
  </.button_link>
</td>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Implementing the `remove-track` event handler
def handle_event("remove-track", %{"path" => path}, socket) do
  socket =
    update(socket, :form, fn form ->
      AshPhoenix.Form.remove_form(form, path)
    end)

  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Removing the order input for tracks, as they are now automatically generated
<.inputs_for :let={track_form} field={@form[:tracks]}>
  <tr data-id={track_form.index}>
    <td class="align-top px-0 w-20"></td>
    <td class="align-top">
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Removing setting the `order` in params - no longer needed once ordering is automatic
update(socket, :form, fn form ->
  AshPhoenix.Form.add_form(form, :tracks)
end)
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Showing how the SortableJS hook is connected
<tbody phx-hook="trackSort" id="trackSort">
  <.inputs_for :let={track_form} field={@form[:tracks]}>
    <tr data-id={track_form.index}>
      <td class="align-top px-3 w-10">
        <span class="hero-bars-3 handle cursor-pointer mt-3" />
      </td>
      <td ...>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Reordering tracks using `sort_forms`
def handle_event("reorder-tracks", %{"order" => order}, socket) do
  socket = update(socket, :form, fn form ->
    AshPhoenix.Form.sort_forms(form, [:tracks], order)
  end)
  {:noreply, socket}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Loading track durations to render on the Album form
def mount(%{"id" => album_id}, _session, socket) do
  album = Tunez.Music.get_album_by_id!(album_id,
    load: [:artist, tracks: [:duration]])
  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using track durations on the Album form
<.inputs_for :let={track_form} field={@form[:tracks]}>
  <tr data-id={track_form.index}>
    <% # ... %>

    <td class="align-top px-0 w-24">
      <label for={track_form[:duration].id} class="hidden">Duration</label>
      <.input field={track_form[:duration]} />
    </td>
# ------------------------------------------------------------------------------
