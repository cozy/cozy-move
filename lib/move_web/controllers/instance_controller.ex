defmodule MoveWeb.InstanceController do
  use MoveWeb, :controller
  @sides ["source", "target"]

  def index(conn, %{"locale" => locale}) do
    assigns = %{
      locale: locale,
      back: Routes.page_path(conn, :index, locale),
      source: "bruno.cozy.works",
      target: nil
    }

    render(conn, "index.html", assigns)
  end

  def select(conn, %{"locale" => locale, "side" => side}) when side in @sides do
    back = Routes.instance_path(conn, :index, locale)
    render(conn, "select.html", back: back, locale: locale, side: side)
  end

  def add(conn, %{"locale" => locale, "side" => side}) when side == "target" do
    back = Routes.instance_path(conn, :select, locale, side)
    render(conn, "add.html", back: back, locale: locale, side: side)
  end

  def edit(conn, %{"locale" => locale, "side" => side}) when side in @sides do
    back =
      if side == "source" do
        Routes.instance_path(conn, :index, locale)
      else
        Routes.instance_path(conn, :select, locale, side)
      end

    render(conn, "edit.html", back: back, locale: locale, side: side)
  end

  def update(conn, %{"locale" => locale, "side" => side, "url" => url, "domain" => domain})
      when side in @sides do
        cozy = if String.starts_with? url, "http" do
          "#{url}#{domain}"
        else
          "https://#{url}#{domain}"
        end
        redirect conn, external: cozy
  end
end
