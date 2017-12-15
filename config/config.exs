# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :telnyx,
  ecto_repos: [Telnyx.Repo]

config :telnyx, Telnyx.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "telnyx_repo",
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :telnyx, TelnyxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iSQeP5qw3IKmB7qusf5bqMllDnAFOFCOs4EFDu7315j36iW09pVd47EdgHUGY3f3",
  render_errors: [view: TelnyxWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Telnyx.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
