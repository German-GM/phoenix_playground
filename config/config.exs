# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

# Montar variables de entorno desde archivo .env
env_file_path = Path.join([Path.dirname(__DIR__), ".env"])

if File.exists?(env_file_path) do
  env_lines =
    File.read!(env_file_path)
    |> String.split("\n")

  Enum.each(env_lines, fn line ->
    line = String.trim(line)

    unless line == "" || String.starts_with?(line, "#") do
      [name, value] = String.split(line, "=", parts: 2)
      name = String.trim(name)
      value = value |> String.trim() |> String.replace("\"", "")
      System.put_env(name, value)
    end
  end)
end

config :playground,
  ecto_repos: [Playground.Repo],
  generators: [timestamp_type: :utc_datetime],
  env: config_env()

# Configures the endpoint
config :playground, PlaygroundWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: PlaygroundWeb.ErrorHTML, json: PlaygroundWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Playground.PubSub,
  live_view: [signing_salt: "FAKV0Ehv"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :playground, Playground.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  playground: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  playground: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
