defmodule MoveWeb.InstanceController do
  use MoveWeb, :controller
  alias MoveWeb.Models.Instance
  alias MoveWeb.Models.Stack

  @sides ["source", "target"]

  def index(conn, %{"locale" => locale}) do
    source = get_session(conn, :source)
    target = get_session(conn, :target)

    assigns = %{
      locale: locale,
      back: Routes.page_path(conn, :index, locale),
      source: source,
      target: target,
      error: Instance.check_valid_move(source, target),
      can_swap: Instance.can_swap(source, target)
    }

    render(conn, "index.html", assigns)
  end

  def swap(conn, %{"locale" => locale}) do
    source = get_session(conn, :source)
    target = get_session(conn, :target)

    conn
    |> put_session("source", target)
    |> put_session("target", source)
    |> configure_session(renew: true)
    |> redirect(to: Routes.instance_path(conn, :index, locale))
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
    back = back_for_edit(conn, locale, side)
    render(conn, "edit.html", back: back, locale: locale, side: side, error: false)
  end

  def update(conn, %{"locale" => locale, "side" => side, "url" => url, "domain" => domain})
      when side in @sides do
    instance = %Instance{url: build_url(url, domain), state: Instance.new_state()}

    case pre_redirect(instance, side) do
      {:ok, instance, url} ->
        conn
        |> put_session(side, instance)
        |> configure_session(renew: true)
        |> redirect(external: url)

      {:error, _} ->
        back = back_for_edit(conn, locale, side)
        render(conn, "edit.html", back: back, locale: locale, side: side, error: true)
    end
  end

  defp back_for_edit(conn, locale, "source"), do: Routes.instance_path(conn, :index, locale)
  defp back_for_edit(conn, locale, side), do: Routes.instance_path(conn, :select, locale, side)

  defp build_url(base, domain) do
    build_base_url(base, domain) |> append_slash
  end

  defp build_base_url(base, domain) do
    cond do
      String.starts_with?(base, "http") -> base
      String.contains?(base, ".") -> "https://#{base}"
      true -> "https://#{base}#{domain}"
    end
  end

  def append_slash(url) do
    if String.ends_with?(url, "/"), do: url, else: url <> "/"
  end

  defp pre_redirect(instance, "source") do
    case Stack.exists(instance) do
      {:ok, _} ->
        state = instance.state |> URI.encode()
        back = Stack.redirect_uri("source") |> URI.encode()
        url = instance.url <> "move/authorize?state=#{state}&redirect_uri=#{back}"
        {:ok, instance, url}

      {:error, error} ->
        {:error, error}
    end
  end

  defp pre_redirect(instance, "target") do
    case Stack.register(instance, "target") do
      {:ok, target} ->
        state = target.state |> URI.encode()
        back = Stack.redirect_uri("target") |> URI.encode()
        client_id = target.client_id |> URI.encode()

        url =
          target.url <>
            "auth/authorize/move?state=#{state}&redirect_uri=#{back}&client_id=#{client_id}"

        {:ok, target, url}

      {:error, error} ->
        {:error, error}
    end
  end

  def create(conn, _params) do
    source = get_session(conn, :source)
    url = source.url <> "move/request"

    conn
    |> clear_session()
    |> put_status(:temporary_redirect)
    |> redirect(external: url)
  end
end
