defmodule MoveWeb.Models.Instance do
  # A URL is formatted like https://move.cozy.example/
  # Disk and quota are numbers (in bytes) but can be nil
  # A code can only be used with a mail confirmation (on the source thus).
  # A token has permission for both exporting and importing
  defstruct [:url, :disk, :quota, :code, :token]

  def quota_error(nil, _target), do: false
  def quota_error(_source, nil), do: false
  # Self-hosted can have unlimited quota
  def quota_error(_source, %Instance{quota: nil}), do: false
  # Unknown disk usage may happen and should not block
  def quota_error(%Instance{disk: nil}, _target), do: false
  def quota_error(%Instance{disk: taken}, %Instance{quota: available}), do: taken > available

  def can_swap(nil, nil), do: false
  def can_swap(nil, _target), do: true
  # A token is required for importing (target)
  def can_swap(%Instance{token: nil}, nil), do: false
  def can_swap(_source, _target), do: true
end
