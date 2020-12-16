defmodule MoveWeb.Features.IntroPageTest do
  use MoveWeb.FeatureCase, async: true

  test "intro page is display with the correct locale", %{session: session} do
    session
    |> visit("/en")
    |> assert_has(Query.css("h1", text: "Move my Cozy"))
  end
end
