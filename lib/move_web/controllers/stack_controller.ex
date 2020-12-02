defmodule MoveWeb.StackController do
  use MoveWeb, :controller
  alias MoveWeb.Models.Instance
  alias MoveWeb.Models.Stack

  def initialize(conn, params) do
    locale = MoveWeb.Models.Headers.get_locale(conn)
    case Stack.initialize_token(params) do
      {:ok, instance} ->
        conn
        |> put_session("source", instance)
        |> configure_session(renew: true)

      _ -> nil # Ignore errors
    end

    instance = %Instance{url: params["cozy_url"], disk: params["used"], quota: params["quota"]}

    redirect(conn, to: Routes.instance_path(conn, :index, locale))
  end

  def callback(conn, %{"side" => side} = params) do
    locale = MoveWeb.Models.Headers.get_locale(conn)
    instance = %Instance{url: "http://#{side}.cozy.tools/", disk: 1_234_456, quota: 5_000_000}

    conn
    |> put_session(side, instance)
    |> configure_session(renew: true)
    |> redirect(to: Routes.instance_path(conn, :index, locale))
  end
end
