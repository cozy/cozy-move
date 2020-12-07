defmodule MoveWeb.Plugs.SetLocale do
  @moduledoc """
  This module provides a plug for setting the locale for gettext from the
  Plug.Conn params.
  """

  @supported_locales Gettext.known_locales(MoveWeb.Gettext)

  def init(_options), do: nil

  def call(%Plug.Conn{params: %{"locale" => locale}} = conn, _options)
      when locale in @supported_locales do
    MoveWeb.Gettext |> Gettext.put_locale(locale)
    conn
  end

  def call(conn, _options), do: conn
end
