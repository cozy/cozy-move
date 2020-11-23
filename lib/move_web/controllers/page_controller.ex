defmodule MoveWeb.PageController do
  use MoveWeb, :controller
  @supported_locales Gettext.known_locales(MoveWeb.Gettext)

  def detect_lang(conn, _params) do
    locale = get_locale_from_header(conn) || "en"
    redirect(conn, to: "/#{locale}")
  end

  defp get_locale_from_header(conn) do
    conn
    |> MoveWeb.Models.Headers.extract_accept_language()
    |> Enum.find(nil, fn l -> Enum.member?(@supported_locales, l) end)
  end

  def index(conn, params) do
    Gettext.put_locale(params["locale"])
    render(conn, "index.html")
  end
end
