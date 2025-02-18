#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-3/lib/tunez/music/artist.ex

# ------------------------------------------------------------------------------
# Context: Adding a custom GIN index to speed up `ilike` queries
postgres do
  table "artists"
  repo Tunez.Repo

  custom_indexes do
    index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a new `search` read action
actions do
  # ...
  read :search do
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining an argument for the new `search` action
actions do
  # ...
  read :search do
    argument :query, :ci_string do
      constraints allow_empty?: true
      default ""
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining a filter in the new `search` action
actions do
  # ...
  read :search do
    argument :query, :ci_string do
      # ...
    end

    filter expr(contains(name, ^arg(:query)))
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding pagination to the `search` action
read :search do
  # ...
  pagination offset?: true, default_limit: 12
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Making attributes public, so they can be sorted by
attributes do
  # ...

  attribute :name, :string do
    allow_nil? false
    public? true
  end

  # ...

  create_timestamp :inserted_at, public?: true
  update_timestamp :updated_at, public?: true
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a new `aggregates` block
defmodule Tunez.Music.Artist do
  # ...

  aggregates do
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding an aggregate for counting albums per artist
aggregates do
  count :album_count, :albums
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding an aggregate to fetch the latest album release year for an artist
aggregates do
  count :album_count, :albums

  # old: calculation
  # calculate :latest_album_year_released, :integer,
  #   expr(first(albums, field: :year_released))

  first :latest_album_year_released, :albums, :year_released
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Ading an aggregate to fetch the most recent album cover image for an artist
aggregates do
  count :album_count, :albums
  first :latest_album_year_released, :albums, :year_released

  # old: calculation
  # calculate :cover_image_url, :string,
  #   expr(first(albums, field: :cover_image_url))

  first :cover_image_url, :albums, :cover_image_url
end

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Making the aggregates public so they can be sorted by
aggregates do
  count :album_count, :albums do
    public? true
  end

  first :latest_album_year_released, :albums, :year_released do
    public? true
  end

  # ...
end
# ------------------------------------------------------------------------------
