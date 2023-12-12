import Config

config :move, MoveWeb.Endpoint,
  http: [port: 4002],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

config :move, MoveWeb.Models.Stack, url: "http://localhost:4002/"

# /!\ The CSP must be configured at compilation time
config :move, MoveWeb.Router,
  csp:
    "default-src 'self'; connect-src 'self'; img-src 'self' data: ; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; font-src 'self'; frame-ancestors 'none'; base-uri 'none';"

config :wallaby, driver: Wallaby.Chrome

config :wallaby, screenshot_dir: "test/screenshots"

config :wallaby, screenshot_on_failure: true
