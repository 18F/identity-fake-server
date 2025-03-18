import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :identity_fake_server, IdentityFakeServerWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "j9Z3Y6ZmZon7RN6dR29vjjWg/UUXdcWG1XNkSmcBDlDQNmP8Cyj0OUW1MMerlFdG",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
