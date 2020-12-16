defmodule MoveWeb.FeatureCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      import MoveWeb.Router.Helpers

      defp for_session(fun) do
        {:ok, mobile} = Wallaby.start_session(window_size: [width: 360, height: 740])
        fun.(mobile, "mobile")
        {:ok, desktop} = Wallaby.start_session(window_size: [width: 1280, height: 720])
        fun.(desktop, "desktop")
      end
    end
  end
end
