defmodule MoveWeb.TestController do
  use MoveWeb, :controller
  alias MoveWeb.Models.Instance

  def fill_side(conn, %{"side" => side} = params) do
    conn
    |> put_session(side, Instance.fake(params))
    |> configure_session(renew: true)
    |> text("ok")
  end
end
