# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :npf,
  ecto_repos: [Npf.Repo]

# Configures the endpoint
config :npf, NpfWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "7ghF29pWeWGTNtT8ElOnNIrxGZzauww6iuda615z0mCD30s5CJ9jQ0s7Xje/IGgh",
  render_errors: [view: NpfWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Npf.PubSub,
  live_view: [signing_salt: "WXuOtMJ+"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
