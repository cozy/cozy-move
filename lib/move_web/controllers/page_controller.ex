defmodule MoveWeb.PageController do
  use MoveWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
