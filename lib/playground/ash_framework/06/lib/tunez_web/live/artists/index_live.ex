#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-6/lib/tunez_web/live/artists/index_live.ex

# ------------------------------------------------------------------------------
# Context: Adding authorization to the `search_artists` function call
def handle_params(params, _url, socket) do
  # ...

  page =
    Tunez.Music.search_artists!(query_text,
      page: page_params,
      query: [sort_input: sort_by],
      actor: socket.assigns.current_user
    )
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding authorization around the "New Artist" button
<.header responsive={false}>
  <% # ... %>
  <:action :if={Tunez.Music.can_create_artist?(@current_user)}>
    <.button_link [opts]>New Artist</.button_link>
  </:action>
</.header>
# ------------------------------------------------------------------------------
