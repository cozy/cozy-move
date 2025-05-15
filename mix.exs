defmodule Move.MixProject do
  use Mix.Project

  def project do
    [
      app: :move,
      version: "1.0.3",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        cozy_move: [
          include_executables_for: [:unix],
          applications: [runtime_tools: :permanent]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Move.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.5.6"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.4.0"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:castore, "~> 0.1"},
      {:mint, "~> 1.0"},
      {:tesla, "~> 1.4", override: true},
      {:number, "~> 1.0"},
      {:wallaby, "~> 0.30", runtime: false, only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      compile_assets: ["cmd npm run deploy --prefix assets", "phx.digest"],
      pretty: ["cmd cd assets && prettier --write --no-semi js/*.js js/*.jsx css/*.css"],
      remove_screenshots: ["cmd rm -rf test/screenshots"],
      setup: ["deps.get", "cmd npm install --prefix assets"],
      teardown: [
        "deps.clean --all",
        "remove_screenshots",
        "cmd rm -rf _build assets/node_modules",
        "cmd which dh_clean > /dev/null && dh_clean || true"
      ],
      test: ["remove_screenshots", "test"]
    ]
  end
end
