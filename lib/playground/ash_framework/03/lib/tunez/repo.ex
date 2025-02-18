#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-3/lib/tunez/repo.ex

# ------------------------------------------------------------------------------
# Context: Adding the `pg_tgrm` PostgreSQL extension to allow for creating the GIN index
defmodule Tunez.Repo do
  use AshPostgres.Repo, otp_app: :tunez

  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions", "pg_trgm"]
  end
# ------------------------------------------------------------------------------
