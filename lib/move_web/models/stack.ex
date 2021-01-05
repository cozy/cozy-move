defmodule MoveWeb.Models.Stack do
  @moduledoc """
  This module provides some helpers for making HTTP call to a cozy-stack.
  """

  use Tesla
  alias MoveWeb.Models.Instance

  @version Mix.Project.config()[:version]

  def redirect_uri(side), do: move_url() <> "callback/" <> side

  def exists(instance) do
    instance.url
    |> client(encode: :json)
    |> Tesla.get("/status")
  end

  def register(instance, side) do
    case post_register(instance.url, side) do
      {:ok, %Tesla.Env{body: %{"error" => error}}} ->
        {:error, error}

      {:ok, %Tesla.Env{body: body}} ->
        {:ok,
         %Instance{instance | client_id: body["client_id"], client_secret: body["client_secret"]}}

      {:error, error} ->
        {:error, error}
    end
  end

  def access_token(instance) do
    case post_access_token(instance) do
      {:ok, %Tesla.Env{body: body}} ->
        {:ok, %Instance{instance | code: "", token: body["access_token"]}}

      {:error, error} ->
        {:error, error}
    end
  end

  defp move_url, do: Application.get_env(:move, __MODULE__, [])[:url]

  defp post_register(base_url, side) do
    headers = [{"accept", "application/json"}]

    body = %{
      "client_name" => "Cozy-Move",
      "client_kind" => "web",
      "client_uri" => move_url(),
      "redirect_uris" => [redirect_uri(side)],
      "software_id" => "github.com/cozy/cozy-move",
      "software_version" => @version
    }

    base_url
    |> client(encode: :json)
    |> Tesla.post("/auth/register", body, headers: headers)
  end

  defp post_access_token(instance) do
    headers = [{"accept", "application/json"}]

    body = %{
      "grant_type" => "authorization_code",
      "code" => instance.code,
      "client_id" => instance.client_id,
      "client_secret" => instance.client_secret
    }

    instance.url
    |> client(encode: :form)
    |> Tesla.post("/auth/access_token", body, headers: headers)
  end

  defp client(base_url, encode: :json), do: client(base_url, Tesla.Middleware.EncodeJson)

  defp client(base_url, encode: :form),
    do: client(base_url, Tesla.Middleware.EncodeFormUrlencoded)

  defp client(base_url, encode_middleware) do
    middleware = [
      {Tesla.Middleware.BaseUrl, base_url},
      {Tesla.Middleware.Timeout, timeout: 10_000},
      {Tesla.Middleware.Retry, max_retries: 1},
      # Tesla.Middleware.Logger,
      Tesla.Middleware.DecodeJson,
      encode_middleware
    ]

    Tesla.client(middleware)
  end
end
