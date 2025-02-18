#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-2/lib/tunez/music/album.ex

# ------------------------------------------------------------------------------
# Context: The initial set of attributes added to the Album resource
attributes do
  uuid_primary_key :id

  attribute :name, :string do
    allow_nil? false
  end

  attribute :year_released, :integer do
    allow_nil? false
  end

  attribute :cover_image_url, :string

  create_timestamp :inserted_at
  update_timestamp :updated_at
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a relationship from Album -> Artist
relationships do
  belongs_to :artist, Tunez.Music.Artist do
    allow_nil? false
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding basic CRUD actions to the Albu resource
actions do
  defaults [:read, :destroy]

  create :create do
    accept [:name, :year_released, :cover_image_url, :artist_id]
  end

  update :update do
    accept [:name, :year_released, :cover_image_url]
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Where to place the new `validations` block in the Album resource
defmodule Tunez.Music.Album do
  # ...

  validations do
    # Validations will go in here
  end
end

# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining a validation for the `year_released` attribute
validations do
  validate numericality(:year_released,
             greater_than: 1950,
             less_than_or_equal_to: &__MODULE__.next_year/0
           ),
           where: [present(:year_released)],
           message: "must be between 1950 and next year"
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: One way of defining a `next_year` function for use in the validation
def next_year, do: Date.utc_today().year + 1
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining a validation for the `cover_image_url` attribute
validations do
  # ...
  validate match(:cover_image_url,
             ~r"(^https://|/images/).+(\.png|\.jpg)$"
           ),
           where: [changing(:cover_image_url)],
           message: "must start with https:// or /images/"
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Defining an identity for `name`/`artist_id` - the combination must be unique
identities do
  identity :unique_album_names_per_artist, [:name, :artist_id],
    message: "already exists for this artist"
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Using PostgreSQL's `on cascade delete` from the Album resource
postgres do
  table "albums"
  repo Tunez.Repo

  references do
    reference :artist, on_delete: :delete
  end
end
# ------------------------------------------------------------------------------
