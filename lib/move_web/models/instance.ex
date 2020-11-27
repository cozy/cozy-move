defmodule MoveWeb.Models.Instance do
  defstruct [:url, :disk, :quota]

  def quota_error(nil, _target), do: false
  def quota_error(_source, nil), do: false
  def quota_error(source, target), do: source.disk > target.quota

  def can_swap(nil, nil), do: false
  def can_swap(_source, _target), do: true
end
