defmodule MoveWeb.StackController do
  use MoveWeb, :controller
  alias MoveWeb.Models.Instance
  alias MoveWeb.Models.Stack

  def initialize(conn, params) do
    locale = MoveWeb.Models.Headers.get_locale(conn)
    source = %Instance{} |> Instance.update_from_params(params)

    case Stack.initialize_token(source) do
      {:ok, instance} ->
        conn
        |> put_session("source", instance)
        |> configure_session(renew: true)

      # Ignore errors
      _ ->
        conn
    end
    |> redirect(to: Routes.instance_path(conn, :index, locale))
  end

  def source(conn, params) do
    locale = MoveWeb.Models.Headers.get_locale(conn)
    source = get_session(conn, "source")

    instance =
      if source.state == params["state"] do
        Instance.update_from_params(source, params)
      else
        %Instance{}
      end

    conn
    |> put_session("source", instance)
    |> configure_session(renew: true)
    |> redirect(to: Routes.instance_path(conn, :index, locale))
  end

  def target(conn, params) do
    locale = MoveWeb.Models.Headers.get_locale(conn)
    target = get_session(conn, "target")

    instance =
      if target.state == params["state"] do
        Instance.update_from_params(target, params)
      else
        %Instance{}
      end

    case Stack.access_token(instance) do
      {:ok, instance} ->
        conn
        |> put_session("target", instance)
        |> configure_session(renew: true)

      # Ignore errors
      _ ->
        conn
    end
    |> redirect(to: Routes.instance_path(conn, :index, locale))
  end
end
