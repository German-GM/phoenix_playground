#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-8/lib/tunez/music/album.ex

# ------------------------------------------------------------------------------
# Context: Adding the relationship between an Album and its Tracks
relationships do
  # ...

  has_many :tracks, Tunez.Music.Track do
    sort order: :asc
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding relationship management for tracks
  actions do
    # ...

    create :create do
      accept [:name, :year_released, :cover_image_url, :artist_id]
      argument :tracks, {:array, :map}
      change manage_relationship(:tracks, type: :direct_control)
    end

    update :update do
      accept [:name, :year_released, :cover_image_url]
      require_atomic? false
      argument :tracks, {:array, :map}
      change manage_relationship(:tracks, type: :direct_control)
    end
  end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using `order_is_key` to automatically manage the order of each track
create :create do
  # ...
  change manage_relationship(:tracks, type: :direct_control,
    order_is_key: :order)
end

update :update do
  # ...
  change manage_relationship(:tracks, type: :direct_control,
    order_is_key: :order)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Calculating duration for an entire album
defmodule Tunez.Music.Album do
  # ...

  aggregates do
    sum :duration_seconds, :tracks, :duration_seconds
  end

  calculations do
    calculate :duration, :string, Tunez.Music.Calculations.SecondsToMinutes
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Making tracks readable over the API
relationships do
  # ...

  has_many :tracks, Tunez.Music.Track do
    sort order: :asc
    public? true
  end

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Making tracks readables over the JSON API
defmodule Tunez.Music.Album do
  # ..

  json_api do
    type "album"
    includes [:tracks]
  end
# ------------------------------------------------------------------------------
