#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-5/lib/tunez_web/router.ex

# ------------------------------------------------------------------------------
# Context: Showing which block of routes need to be moved, to allow liveview authentication
scope "/", TunezWeb do
  pipe_through :browser

  # This is the block of routes to move
  live "/", Artists.IndexLive
  # ...
  live "/albums/:id/edit", Albums.FormLive, :edit

  auth_routes AuthController, Tunez.Accounts.User, path: "/auth"
  sign_out_route AuthController
  ...
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Showing where the block of routes should be moved to, to allow liveview authentication
scope "/", TunezWeb do
  pipe_through :browser

  ash_authentication_live_session :authenticated_routes do
    # This is the location that the block of routes should be moved to
    live "/", Artists.IndexLive
    # ...
    live "/albums/:id/edit", Albums.FormLive, :edit
  end
end
# ------------------------------------------------------------------------------
