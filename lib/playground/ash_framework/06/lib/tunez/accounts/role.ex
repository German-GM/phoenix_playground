#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-6/lib/tunez/accounts/role.ex

# ------------------------------------------------------------------------------
# Context: Defining an `Ash.Type.Enum` to represent user roles
defmodule Tunez.Accounts.Role do
  use Ash.Type.Enum, values: [:admin, :editor, :user]
end
# ------------------------------------------------------------------------------
