defmodule MoveWeb.Models.Instance do
  @moduledoc """
  This module provides a struct for instances that can be persisted as cookies.
  And there are a few related functions that work with this struct.
  """

  alias MoveWeb.Models.Instance

  # Use 16 bytes of entropy for states
  @state_length 16

  # A URL is formatted like https://source.cozy.example/
  # Disk and quota are numbers (in bytes) but can be nil.
  # Vault is a boolean to indicate if the user has a vault to move.
  # A code can only be used with a mail confirmation (on the source thus).
  # A token has permission for both exporting and importing.
  # State, client_id, and client_secret are used to exchange secrets between
  # move and the stack.
  defstruct [:url, :disk, :quota, :vault, :code, :token, :state, :client_id, :client_secret]

  def check_valid_move(source, target) do
    cond do
      same_instance(source, target) -> :same
      quota_error(source, target) -> :quota
      true -> nil
    end
  end

  def same_instance(nil, _target), do: false
  def same_instance(_source, nil), do: false
  def same_instance(source, target), do: source.url == target.url

  def quota_error(nil, _target), do: false
  def quota_error(_source, nil), do: false
  # Self-hosted can have unlimited quota
  def quota_error(_source, %Instance{quota: nil}), do: false
  # Unknown disk usage may happen and should not block
  def quota_error(%Instance{disk: nil}, _target), do: false
  def quota_error(_source, %Instance{quota: nil}), do: false

  def quota_error(%Instance{disk: taken}, %Instance{quota: available}),
    do: String.to_integer(taken) > String.to_integer(available)

  def can_swap(nil, nil), do: false
  def can_swap(nil, _target), do: true
  # A token is required for importing (target)
  def can_swap(%Instance{token: nil}, nil), do: false
  def can_swap(_source, _target), do: true

  def update_from_params(instance, params) do
    %Instance{
      instance
      | url: params["cozy_url"] || instance.url,
        code: params["code"],
        disk: params["used"],
        quota: params["quota"],
        vault: params["vault"] == "true",
        state: new_state()
    }
  end

  def update_client(instance, params) do
    %Instance{
      instance
      | client_id: params["client_id"],
        client_secret: params["client_secret"]
    }
  end

  def new_state do
    :crypto.strong_rand_bytes(@state_length)
    |> Base.url_encode64(padding: false)
    |> binary_part(0, @state_length)
  end

  def fake(params) do
    url =
      if params["side"] == "source",
        do: "http://source.cozy.tools/",
        else: "http://target.cozy.tools/"

    %Instance{
      url: url,
      disk: params["disk"] || "123456789",
      quota: params["quota"] || "5000000000",
      vault: params["vault"] == "true",
      token: "xxx"
    }
  end
end
