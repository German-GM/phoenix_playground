#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-6/lib/tunez/music/artist.ex

# ------------------------------------------------------------------------------
# Context: Enabling authorization for the Artist resource
defmodule Tunez.Music.Artist do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Temporarily allowing all users to create Artist records
defmodule Tunez.Music.Artist do
  # ...

  policies do
    policy action(:create) do
      authorize_if always()
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a policy to allow admins to create Artist records
policies do
  policy action(:create) do
    authorize_if actor_attribute_equals(:role, :admin)
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding policies for Artist update and destroy actions
policies do
  # ...

  policy action(:update) do
    authorize_if actor_attribute_equals(:role, :admin)
    authorize_if actor_attribute_equals(:role, :editor)
  end

  policy action(:destroy) do
    authorize_if actor_attribute_equals(:role, :admin)
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add a policy to allow all users to read Artist records
policies do
  # ...

  policy action_type(:read) do
    authorize_if always()
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding relationships to track who created/updated an Artist record
relationships do
  # ...
  belongs_to :created_by, Tunez.Accounts.User
  belongs_to :updated_by, Tunez.Accounts.User
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding resource-level changes to save who created/updated an Artist record
defmodule Tunez.Music.Artist do
  # ...

  changes do
    change relate_actor(:created_by, allow_nil?: true), on: [:create]
    change relate_actor(:updated_by, allow_nil?: true), on: [:create]

    change relate_actor(:updated_by, allow_nil?: false), on: [:update]
  end
end
# ------------------------------------------------------------------------------
