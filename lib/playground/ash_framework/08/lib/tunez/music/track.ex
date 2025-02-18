#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-8/lib/tunez/music/track.ex

# ------------------------------------------------------------------------------
# Context: Adding initial attributes for the Track resource
defmodule Tunez.Music.Track do
  # ...

  attributes do
    uuid_primary_key :id

    attribute :order, :integer do
      allow_nil? false
    end

    attribute :name, :string do
      allow_nil? false
    end

    attribute :duration_seconds, :integer do
      allow_nil? false
      constraints min: 1
    end

    create_timestamp :inserted_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :album, Tunez.Music.Album do
      allow_nil? false
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Setting up a database reference so that when an album is deleted, its
# tracks are also deleted
postgres do
  table "tracks"
  repo Tunez.Repo

  references do
    reference :album, on_delete: :delete
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding basic CRUD actions for managing track data
defmodule Tunez.Music.Track do
  # ...

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:order, :name, :duration_seconds, :album_id]
    end

    update :update do
      primary? true
      accept [:order, :name, :duration_seconds]
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Inheriting policies from a parent Album resource
defmodule Tunez.Music.Track do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  policies do
    policy always() do
      authorize_if accessing_from(Tunez.Music.Album, :tracks)
    end
  end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Always allowing reads for tracks
policy always() do
  authorize_if accessing_from(Tunez.Music.Album, :tracks)
  authorize_if action_type(:read)
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining a human-readable `number` calculation
defmodule Tunez.Music.Track do
  # ...

  calculations do
    calculate :number, :integer, expr(order + 1)
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a calculation for a human-readable `duration` attribute
calculations do
  calculate :number, :integer, expr(order + 1)
  calculate :duration, :string, Tunez.Music.Calculations.SecondsToMinutes
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Accepting a string version of a duration, instead of a number of seconds
actions do
  # ...

  create :create do
    primary? true
    accept [:order, :name, :album_id]
    argument :duration, :string, allow_nil?: false
    change Tunez.Music.Changes.MinutesToSeconds, only_when_valid?: true
  end

  update :update do
    primary? true
    accept [:order, :name]
    require_atomic? false
    argument :duration, :string, allow_nil?: false
    change Tunez.Music.Changes.MinutesToSeconds, only_when_valid?: true
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Making attributes readable over the API
attributes do
  # ...

  attribute :name, :string do
    allow_nil? false
    public? true
  end

  # ...
end

calculations do
  calculate :number, :integer, expr(order + 1), public?: true
  calculate :duration, :string, Tunez.Music.Calculations.SecondsToMinutes,
    public?: true
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Setting the default Track fields to be returned in JSON:API responses
json_api do
  type "track"
  default_fields [:number, :name, :duration]
end
# ------------------------------------------------------------------------------
