#---
# Excerpted from "Ash Framework",
# published by The Pragmatic Bookshelf.
# Copyrights apply to this code. It may not be used to create training material,
# courses, books, articles, and the like. Contact us if you are in doubt.
# We make no guarantees that this code is fit for any purpose.
# Visit https://pragprog.com/titles/ldash for more book information.
#---
# The final version of this file at the end of this chapter can be found at
# https://github.com/sevenseacat/tunez/blob/end-of-chapter-4/lib/tunez_web/router.ex

# ------------------------------------------------------------------------------
# Context: Showing how SwaggerUI documentation is configured in the Phoenix router
scope "/api/json" do
  pipe_through [:api]

  forward "/swaggerui",
          OpenApiSpex.Plug.SwaggerUI,
          path: "/api/json/open_api",
          default_model_expand_depth: 4

  forward "/", TunezWeb.AshJsonApiRouter
end
# ------------------------------------------------------------------------------
