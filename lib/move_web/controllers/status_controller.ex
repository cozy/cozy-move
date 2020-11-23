defmodule MoveWeb.StatusController do
  use MoveWeb, :controller

  def index(conn, _params) do
    json(conn, %{status: "OK"})
  end
end
