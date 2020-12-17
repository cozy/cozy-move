defmodule MoveWeb.Router do
  use MoveWeb, :router

  # credo:disable-for-next-line
  @csp Application.get_env(:move, __MODULE__, false)[:csp]

  # Enables LiveDashboard only for development
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MoveWeb.Telemetry
      get "/test/:side", MoveWeb.TestController, :fill_side
    end
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :put_secure_browser_headers, %{"content-security-policy" => @csp}
  end

  scope "/", MoveWeb do
    pipe_through :api
    get "/status", StatusController, :index
    post "/initialize", StackController, :initialize
    get "/callback/source", StackController, :source
    get "/callback/target", StackController, :target
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers, %{"content-security-policy" => @csp}
    plug MoveWeb.Plugs.SetLocale
  end

  scope "/", MoveWeb do
    pipe_through :browser
    get "/", PageController, :detect_lang
  end

  scope "/:locale", MoveWeb do
    pipe_through :browser
    get "/", PageController, :index
    get "/instances", InstanceController, :index
    post "/instances", InstanceController, :create
    post "/instances/swap", InstanceController, :swap
    get "/:side/select", InstanceController, :select
    get "/:side/add", InstanceController, :add
    get "/:side/edit", InstanceController, :edit
    post "/:side", InstanceController, :update
  end
end
