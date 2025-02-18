#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-6/lib/tunez/accounts/user.ex

# ------------------------------------------------------------------------------
# Context: The default policies generated for users, when installing AshAuthentication
defmodule Tunez.Accounts.User do
  # ...
  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      forbid_if always()
    end
  end
  # ...
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a custom policy to allow public access to the register/sign-in actions
policies do
  bypass AshAuthentication.Checks.AshAuthenticationInteraction do
    authorize_if always()
  end

  policy action([:register_with_password, :sign_in_with_password]) do
    authorize_if always()
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding the new `role` attribute to the User resource
attributes do
  # ...

  attribute :role, Tunez.Accounts.Role do
    allow_nil? false
    default :user
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a new action to change a user's role
actions do
  defaults [:read]

  update :set_role do
    accept [:role]
  end

  # ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a new policy to allow users to read their own user records
policies do
  # ...
  policy action(:read) do
    authorize_if expr(id == ^actor(:id))
  end
end
# ------------------------------------------------------------------------------
