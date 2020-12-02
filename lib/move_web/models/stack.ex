defmodule MoveWeb.Models.Stack do
  use Tesla
  alias MoveWeb.Models.Instance

  @config Application.get_env(:move, __MODULE__, [])

  def initialize_token(params) do
    url = params["cozy_url"]

    case post_initialize_token(url, params["code"]) do
      {:ok, %Tesla.Env{body: body}} ->
        {:ok,
         %Instance{
           url: url,
           token: body["access_token"],
           disk: params["used"],
           quota: params["quota"]
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  def register(instance, side) do
    case post_register(instance.url, side) do
      {:ok, %Tesla.Env{body: body}} ->
        {:ok,
         %Instance{instance | client_id: body["client_id"], client_secret: body["client_secret"]}}

      {:error, error} ->
        {:error, error}
    end
  end

  def redirect_uri(side), do: @config[:url] <> "callback/" <> side

  defp post_initialize_token(base_url, token) do
    headers = [{"accept", "application/json"}]

    body = %{"token" => token}

    base_url
    |> client(encode: :form)
    |> Tesla.post("/move/access_token", body, headers: headers)
  end

  defp post_register(base_url, side) do
    headers = [{"accept", "application/json"}]

    body = %{
      "client_name" => "Cozy-Move",
      "client_kind" => "web",
      "client_uri" => @config[:url],
      "redirect_uris" => [redirect_uri(side)],
      "software_id" => "github.com/cozy/cozy-move",
      "software_version" => Mix.Project.config()[:version]
    }

    base_url
    |> client(encode: :json)
    |> Tesla.post("/auth/register", body, headers: headers)
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
