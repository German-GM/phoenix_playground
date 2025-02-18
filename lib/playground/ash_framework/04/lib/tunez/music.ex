#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-4/lib/tunez/music.ex

# ------------------------------------------------------------------------------
# Context: Adding endpoints for artist actions to the JSON API
defmodule Tunez.Music do
  # ...

  json_api do
    routes do
      base_route "/artists", Tunez.Music.Artist do
        get :read
        index :search
        post :create
        patch :update
        delete :destroy
      end
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding endpoints for album actions to the JSON API
json_api do
  routes do
    # ...

    base_route "/albums", Tunez.Music.Album do
      post :create
      patch :update
      delete :destroy
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding an endpoint for fetching albums for a given artist, to the JSON API
base_route "/artists", Tunez.Music.Artist do
  # ...
  related :albums, :read, primary?: true
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding queries for reading artist records to the GraphQL API
defmodule Tunez.Music do
  # ...

  graphql do
    queries do
      get Tunez.Music.Artist, :get_artist_by_id, :read
      list Tunez.Music.Artist, :search_artists, :search
    end
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding mutations for managing artist records to the GraphQL API
graphql do
  # ...

  mutations do
    create Tunez.Music.Artist, :create_artist, :create
    update Tunez.Music.Artist, :update_artist, :update
    destroy Tunez.Music.Artist, :destroy_artist, :destroy
  end
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Adding mutations for managing album records to the GraphQL API
graphql do
  mutations do
    # ...

    create Tunez.Music.Album, :create_album, :create
    update Tunez.Music.Album, :update_album, :update
    destroy Tunez.Music.Album, :destroy_album, :destroy
  end
end
# ------------------------------------------------------------------------------
