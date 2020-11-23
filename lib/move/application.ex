defmodule Move.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      MoveWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Move.PubSub},
      # Start the Endpoint (http/https)
      MoveWeb.Endpoint
      # Start a worker by calling: Move.Worker.start_link(arg)
      # {Move.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Move.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    MoveWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
