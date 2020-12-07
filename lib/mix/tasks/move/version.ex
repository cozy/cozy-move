defmodule Mix.Tasks.Move.Version do
  @moduledoc """
  This module adds a mix version command.
  """

  use Mix.Task

  def run(_) do
    IO.puts(Mix.Project.config()[:version])
  end
end
