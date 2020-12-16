defmodule MoveWeb.FeatureCase do
  use ExUnit.CaseTemplate

  using do
    quote do
      use Wallaby.Feature

      import MoveWeb.Router.Helpers
    end
  end
end
