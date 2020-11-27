defmodule MoveWeb.InstanceController do
  use MoveWeb, :controller
  alias MoveWeb.Models.Instance, as: Instance
  @sides ["source", "target"]

  def index(conn, %{"locale" => locale}) do
    source = get_session(conn, :source)
    target = get_session(conn, :target)

    assigns = %{
      locale: locale,
      back: Routes.page_path(conn, :index, locale),
      source: source,
      target: target,
      error: Instance.quota_error(source, target)
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

  def update(conn, %{"locale" => _locale, "side" => side, "url" => url, "domain" => domain})
      when side in @sides do
    cozy = build_url(url, domain)
    redirect(conn, external: cozy)
  end

  defp build_url(base, domain) do
    cond do
      String.starts_with?(base, "http") ->
        base

      String.contains?(base, ".") ->
        "https://#{base}"

      true ->
        "https://#{base}#{domain}"
    end
  end

  def create(conn, %{"url" => url}) do
    locale = MoveWeb.Models.Headers.get_locale(conn)
    instance = %Instance{url: url, disk: 1_234_456, quota: 5_000_000}

    conn
    |> put_session(side, instance)
    |> configure_session(renew: true)
    |> redirect(to: Routes.instance_path(conn, :index, locale))
  end
end
