#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-6/lib/tunez/accounts.ex

# ------------------------------------------------------------------------------
# Context: Add metadata to be returned as part of the registration API response
post :register_with_password do
  route "/register"

  metadata fn _subject, user, _request ->
    %{token: user.__metadata__.token}
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add a JSON API endpoint for user sign-in, with metadata
base_route "/users", Tunez.Accounts.User do
  # ...

  post :sign_in_with_password do
    route "/sign_in"

    metadata fn _subject, user, _request ->
      %{token: user.__metadata__.token}
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add a GraphQL mutation for user registration
defmodule Tunez.Accounts do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  graphql do
    mutations do
      create Tunez.Accounts.User, :register_with_password, :register_with_password
    end
  end
  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add a GraphQL query for user sign-in
defmodule Tunez.Accounts do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  graphql do
    queries do
      get Tunez.Accounts.User, :sign_in_with_password, :sign_in_with_password
    end

    # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add a custom type to allow metadata to be returned in the GraphQL response
queries do
  get Tunez.Accounts.User, :sign_in_with_password, :sign_in_with_password do
    identity false
    type_name :user_with_token
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add code interface functions to allow the helper functions to be called
# more easily from `iex`
defmodule Tunez.Accounts do
  # ...

  resources do
    # ...
    resource Tunez.Accounts.User do
      define :set_user_role, action: :set_role, args: [:role]
      define :get_user_by_id, action: :read, get_by: [:id]
    end
# ------------------------------------------------------------------------------
