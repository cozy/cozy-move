defmodule MoveWeb.PageController do
  use MoveWeb, :controller
  alias MoveWeb.Models.Headers

  def detect_lang(conn, _params) do
    locale = Headers.get_locale(conn)
    redirect(conn, to: Routes.page_path(conn, :index, locale))
  end

  def index(conn, %{"locale" => locale}) do
    render(conn, "index.html", back: false, locale: locale)
  end
end
