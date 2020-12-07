use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :move, MoveWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :move, MoveWeb.Models.Stack, url: "http://localhost:4002/"

# /!\ The CSP must be configured at compilation time
config :move, MoveWeb.Router,
  csp:
    "default-src 'self'; connect-src 'self'; img-src 'self' data: ; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self'; font-src 'self'; frame-ancestors 'none'; base-uri 'none';"
