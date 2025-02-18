#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-3/lib/tunez_web/live/artists/index_live.ex

# ------------------------------------------------------------------------------
# Context: The existing code to read all artists for the Artist catalog
def handle_params(_params, _url, socket) do
  artists = Tunez.Music.read_artists!()

  socket =
    socket
    |> assign(:artists, artists)
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Replacing the `read_artists` function with a search using a query from the URL
def handle_params(params, _url, socket) do
  query_text = Map.get(params, "q", "")
  artists = Tunez.Music.search_artists!(query_text)

  socket =
    socket
    |> assign(:query_text, query_text)
    |> assign(:artists, artists)
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a search box to allow users to enter search queries
<.header responsive={false}>
  <.h1>Artists</.h1>
  <:action>
    <.search_box query={@query_text} method="get"
                 data-role="artist-search" phx-submit="search" />
  </:action>
  <:action>
    <.button_link
      # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Implementing the logic to update the URL when a search query is submitted
def handle_event("search", %{"query" => query}, socket) do
  params = remove_empty(%{q: query})
  {:noreply, push_patch(socket, to: ~p"/?#{params}")}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Before converting the `search_artists` function call to use pagination
def handle_params(params, _url, socket) do
  # ...
  artists = Tunez.Music.search_artists!(query_text, query: [sort_input: sort_by])

  socket =
    socket
    |> assign(:query_text, query_text)
    |> assign(:artists, artists)
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Renaming the variable to reflect that it now uses pagination
def handle_params(params, _url, socket) do
  # ...
  page = Tunez.Music.search_artists!(query_text, query: [sort_input: sort_by])

  socket =
    socket
    |> assign(:query_text, query_text)
    |> assign(:page, page)
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Updating the template code to use the paginated artist results
<div :if={@page.results == []} class="p-8 text-center">
  <.icon name="hero-face-frown" class="w-32 h-32 bg-base-300" />
  <br /> No artist data to display!
</div>

<ul class="gap-6 lg:gap-12 grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4">
  <li :for={artist <- @page.results}>
    <.artist_card artist={artist} />
  </li>
</ul>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add the pagination link function component to the template (currently static)
def render(assigns)
  ~H"""
  <% # ... %>

  <.pagination_links page={@page} query_text={@query_text} sort_by={@sort_by} />
  """
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Making the static `pagination_links` component functional
<div
  :if={AshPhoenix.LiveView.prev_page?(@page) ||
       AshPhoenix.LiveView.next_page?(@page)}
  class="flex justify-center pt-8 join"
>
  <.button_link data-role="previous-page"
    patch={~p"/?#{query_string(@page, @query_text, @sort_by, "prev")}"}
    disabled={!AshPhoenix.LiveView.prev_page?(@page)}
    class="join-item" kind="primary" outline
  >
    « Previous
  </.button_link>
  <.button_link data-role="next-page"
    patch={~p"/?#{query_string(@page, @query_text, @sort_by, "next")}"}
    disabled={!AshPhoenix.LiveView.next_page?(@page)}
    class="join-item" kind="primary" outline
  >
    Next »
  </.button_link>
</div>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding pagination links that include page, sort and search query information
def query_string(page, query_text, sort_by, which) do
  case AshPhoenix.LiveView.page_link_params(page, which) do
    :invalid -> []
    list -> list
  end
  |> Keyword.put(:q, query_text)
  |> Keyword.put(:sort_by, sort_by)
  |> remove_empty()
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using the page information from the URL to select the correct page of data from the database
def handle_params(params, _url, socket) do
  # ...
  page_params = AshPhoenix.LiveView.page_from_params(params, 12)

  page =
    Tunez.Music.search_artists!(query_text,
      page: page_params,
      query: [sort_input: sort_by]
    )
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a sorting method selector to the template
<.header responsive={false}>
  <.h1>Artists</.h1>
  <:action><.sort_changer selected={@sort_by} /></:action>
  <:action>
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Setting up a variable to store the currently-selected sort method
def handle_params(params, _url, socket) do
  sort_by = nil
  # ...

  socket =
    socket
    |> assign(:sort_by, sort_by)
    |> assign(:query_text, query_text)
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Reacting to changes in the sorting method selector and updating the URL
def handle_event("change_sort", %{"sort_by" => sort_by}, socket) do
  params = remove_empty(%{q: socket.assigns.query_text, sort_by: sort_by})
  {:noreply, push_patch(socket, to: ~p"/?#{params}")}
end

def handle_event("search", %{"query" => query}, socket) do
  params = remove_empty(%{q: query, sort_by: socket.assigns.sort_by})
  {:noreply, push_patch(socket, to: ~p"/?#{params}")}
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The default list of sorting methods
def sort_options do
  [
    {"updated_at", "recently updated"},
    {"inserted_at", "recently added"},
    {"name", "name"}
  ]
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Reading the sorting method from the URL and ensuring that it's valid
def handle_params(params, _url, socket) do
  sort_by = Map.get(params, "sort_by") |> validate_sort_by()
  # ...

  socket =
    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using the supplied sorting method when searching artists
def handle_params(params, _url, socket) do
  # ...
  artists = Tunez.Music.search_artists!(query_text, query: [sort_input: sort_by])
  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Update `updated_at` and `inserted_at` to sort in descending order
def sort_options do
  [
    {"-updated_at", "recently updated"},
    {"-inserted_at", "recently added"},
    {"name", "name"}
  ]
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: The template code that renders the artist cover image
<div id={"artist-#{@artist.id}"} data-role="artist-card" class="relative mb-2">
  <.link navigate={~p"/artists/#{@artist}"}>
    <.cover_image />
  </.link>
</div>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Updating the template code to use the aggregate attribute from the artist
<div id={"artist-#{@artist.id}"} data-role="artist-card" class="relative mb-2">
  <.link navigate={~p"/artists/#{@artist}"}>
    <.cover_image image={@artist.cover_image_url} />
  </.link>
</div>
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding album count/latest release year information for each artist to the catalog
def artist_card(assigns) do
  ~H"""
  <% # ... %>

  <.artist_card_album_info artist={@artist} />
  """
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding aggregates to the list of sorting methods
def sort_options do
  [
    {"-updated_at", "recently updated"},
    {"-inserted_at", "recently added"},
    {"name", "name"},
    {"-album_count", "number of albums"},
    {"--latest_album_year_released", "latest album release"}
  ]
end
# ------------------------------------------------------------------------------
