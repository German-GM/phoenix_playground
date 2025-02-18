#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-5/lib/tunez/accounts.ex

# ------------------------------------------------------------------------------
# Context: Add a JSON API endpoint for user registration
defmodule Tunez.Accounts do
  use Ash.Domain, extensions: [AshJsonApi.Domain]

  json_api do
    routes do
      base_route "/users", Tunez.Accounts.User do
        post :register_with_password, route: "/register"
      end
    end
  end

  # ...
end
# ------------------------------------------------------------------------------
