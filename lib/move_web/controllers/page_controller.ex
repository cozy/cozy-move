defmodule MoveWeb.PageController do
  use MoveWeb, :controller
  @supported_locales Gettext.known_locales(MoveWeb.Gettext)

  def detect_lang(conn, _params) do
    locale = get_locale_from_header(conn) || "en"
    redirect(conn, to: Routes.page_path(conn, :index, locale))
  end

  defp get_locale_from_header(conn) do
    conn
    |> MoveWeb.Models.Headers.extract_accept_language()
    |> Enum.find(nil, fn l -> Enum.member?(@supported_locales, l) end)
  end

  def index(conn, %{"locale" => locale}) do
    render(conn, "index.html", back: false, locale: locale)
  end
end
