import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :vecchio_api, VecchioApiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "S3HqJIXD7pCTP3iUbmJjtkaqVeyip6+IAQVVkgUuLL60eSfGbK85UmGgbZ4tXxDa",
  server: false

config :vecchio_api, VecchioApi.Repo,
  url: System.get_env("DATABASE_URL_TESTE"),
  pool_size: 10,
  timeout: 60_000,
  idle_interval: 10_000,
  queue_target: 5_000,
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  auth_source: "admin"

# In test we don't send emails
config :vecchio_api, VecchioApi.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

config :vecchio_api, VecchioApi.Repo,
  database: System.get_env("DATABASE_NAME") <> "_teste",
  url: System.get_env("DATABASE_URL_TESTE"),
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  auth_source: "admin"

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
