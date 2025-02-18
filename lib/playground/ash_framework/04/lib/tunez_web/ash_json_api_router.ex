#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-4/lib/tunez_web/ash_json_api_router.ex

# ------------------------------------------------------------------------------
# Context: Showing OpenAPI support automatically added to the AshJsonApiRouter
defmodule TunezWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat([Tunez.Music])],
    open_api: "/open_api"
end
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Context: Showing how to customize details of the generated OpenAPI schema document
defmodule TunezWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat([Tunez.Music])],
    open_api: "/open_api",
    open_api_title: "Tunez API Documentation",
    open_api_version: to_string(Application.spec(:tunez, :vsn))
end
# ------------------------------------------------------------------------------
