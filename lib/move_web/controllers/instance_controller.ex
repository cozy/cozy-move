defmodule MoveWeb.InstanceController do
  use MoveWeb, :controller

  def index(conn, %{"locale" => locale}) do
    back = Routes.page_path(conn, :index, locale)
    render(conn, "index.html", back: back, locale: locale)
  end
end
