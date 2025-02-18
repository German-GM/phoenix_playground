#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-6/lib/tunez/music/album.ex

# ------------------------------------------------------------------------------
# Context: Adding relationships to track who created/updated an Album record
relationships do
  # ...
  belongs_to :created_by, Tunez.Accounts.User
  belongs_to :updated_by, Tunez.Accounts.User
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding resource-level changes to save who created/updated an Album record
defmodule Tunez.Music.Album do
  # ...

  changes do
    change relate_actor(:created_by, allow_nil?: true), on: [:create]
    change relate_actor(:updated_by, allow_nil?: true), on: [:create]

    change relate_actor(:updated_by, allow_nil?: false), on: [:update]
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Enabling authorization for the Album resource
defmodule Tunez.Music.Album do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding a bypass to allow admins to run all actions
defmodule Tunez.Music.Album do
  # ...

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add a policy to all users to run read actions
policies do
  # ...

  policy action_type(:read) do
    authorize_if always()
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add a policy to allow editors to create new Album records
policies do
  # ...

  policy action(:create) do
    authorize_if actor_attribute_equals(:role, :editor)
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Add a policy to allow editors to delete Album records if they created them
policies do
  # ...

  policy action_type([:update, :destroy]) do
    authorize_if expr(^actor(:role) == :editor and created_by_id == ^actor(:id))
  end
end
# ------------------------------------------------------------------------------
