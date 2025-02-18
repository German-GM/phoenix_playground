#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-4/lib/tunez/music/album.ex

# ------------------------------------------------------------------------------
# Context: Making attributes public so they can be returned in API responses
attributes do
  uuid_primary_key :id

  attribute :name, :string do
    allow_nil? false
    public? true
  end

  attribute :year_released, :integer do
    allow_nil? false
    public? true
  end

  attribute :cover_image_url, :string do
    public? true
  end

  # ...
# ------------------------------------------------------------------------------
