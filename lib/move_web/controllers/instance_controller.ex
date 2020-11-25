defmodule MoveWeb.InstanceController do
  use MoveWeb, :controller
  @sides ["source", "target"]

  def index(conn, %{"locale" => locale}) do
    back = Routes.page_path(conn, :index, locale)
    render(conn, "index.html", back: back, locale: locale)
  end

  def select(conn, %{"locale" => locale, "side" => side}) when side in @sides do
    back = Routes.instance_path(conn, :index, locale)
    render(conn, "select.html", back: back, locale: locale, side: side)
  end

  def add(conn, %{"locale" => locale, "side" => side}) when side in @sides do
    back = Routes.instance_path(conn, :select, locale, side)
    render(conn, "add.html", back: back, locale: locale, side: side)
  end
end
