defmodule MoveWeb.Features.IntroPageTest do
  use MoveWeb.FeatureCase, async: true

  feature "intro page can be displayed in english", %{session: session} do
    session
    |> visit("/en")
    |> assert_has(Query.css("h1", text: "Move my Cozy"))
    |> take_screenshot(name: "intro_en")
  end

  feature "intro page can be displayed in french", %{session: session} do
    session
    |> visit("/fr")
    |> assert_has(Query.css("h1", text: "Déménager mon Cozy"))
    |> take_screenshot(name: "intro_fr")
  end
end
