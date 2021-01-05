defmodule Mix.Tasks.Move.Version do
  @moduledoc """
  This module adds a mix move.version command.
  """

  use Mix.Task

  @version Mix.Project.config[:version]

  def run(_) do
    IO.puts(@version)
  end
end
