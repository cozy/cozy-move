defmodule MoveWeb.Models.Instance do
  alias MoveWeb.Models.Instance

  # Use 16 bytes of entropy for states
  @state_length 16

  # A URL is formatted like https://source.cozy.example/
  # Disk and quota are numbers (in bytes) but can be nil.
  # A code can only be used with a mail confirmation (on the source thus).
  # A token has permission for both exporting and importing.
  # State, client_id, and client_secret are used to exchange secrets between
  # move and the stack.
  defstruct [:url, :disk, :quota, :code, :token, :state, :client_id, :client_secret]

  def quota_error(nil, _target), do: false
  def quota_error(_source, nil), do: false
  # Self-hosted can have unlimited quota
  def quota_error(_source, %Instance{quota: nil}), do: false
  # Unknown disk usage may happen and should not block
  def quota_error(%Instance{disk: nil}, _target), do: false
  def quota_error(_source, %Instance{quota: nil}), do: false
  def quota_error(%Instance{disk: taken}, %Instance{quota: available}), do: taken > available

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

  def new_state() do
    :crypto.strong_rand_bytes(@state_length)
    |> Base.encode64(padding: false)
    |> binary_part(0, @state_length)
  end
end
