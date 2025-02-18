#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-4/lib/tunez/music/artist.ex

# ------------------------------------------------------------------------------
# Context: Making attributes public so they can be returned in API responses
attributes do
  # ...
  attribute :biography, :string do
    public? true
  end

  attribute :previous_names, {:array, :string} do
    default []
    public? true
  end
  # ...
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Allowing albums to be included when fetching artist data via the JSON API
json_api do
  type "artist"
  includes [:albums]
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Making relationships public so they can be returned in API responses
relationships do
  has_many :albums, Tunez.Music.Album do
    sort year_released: :desc
    public? true
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Disabling the auto-generated filter for Artists in the JSON API
json_api do
  type "artist"
  includes [:albums]
  derive_filter? false
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Specifying which fields may be filtered on in the GraphQL API
graphql do
  type :artist
  filterable_fields [:album_count, :cover_image_url, :inserted_at,
    :latest_album_year_released, :updated_at]
end
# ------------------------------------------------------------------------------
