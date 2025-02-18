#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-5/lib/tunez_web/auth_overrides.ex

# ------------------------------------------------------------------------------
# Context: Showing a sample of how to add overrides for AshAuthentication components
override AshAuthentication.Phoenix.Components.Banner do
  set :image_url, "https://media.giphy.com/media/g7GKcSzwQfugw/giphy.gif"
  set :text_class, "bg-red-500"
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Testing a first override for changing submit button styles
defmodule TunezWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides

  override AshAuthentication.Phoenix.Components.Password.Input do
    set :submit_class, "phx-submit-loading:opacity-75 btn btn-primary"
  end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Show what the first part of the AuthOverrides file should look like
# after copying the provided overrides in
defmodule TunezWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides
  alias AshAuthentication.Phoenix.Components

  override Components.Banner do
    set :image_url, nil
    # ...
# ------------------------------------------------------------------------------
