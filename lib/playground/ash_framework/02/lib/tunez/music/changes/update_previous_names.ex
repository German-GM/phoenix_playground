#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-2/lib/tunez/music/changes/update_previous_names.ex

# ------------------------------------------------------------------------------
# Context: How to move an inline anonymous change function into a separate change module
defmodule Tunez.Music.Changes.UpdatePreviousNames do
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    # The code previously in the body of the anonymous change function
  end
end
# ------------------------------------------------------------------------------
