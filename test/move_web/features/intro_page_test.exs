defmodule MoveWeb.Features.IntroPageTest do
  use MoveWeb.FeatureCase, async: true

  test "intro page can be displayed in english" do
    for_session(fn session, suffix ->
      session
      |> visit("/en")
      |> assert_has(Query.css("h1", text: "Move my Cozy"))
      |> take_screenshot(name: "intro_en_#{suffix}")
    end)
  end

  test "intro page can be displayed in french" do
    for_session(fn session, suffix ->
      session
      |> visit("/fr")
      |> assert_has(Query.css("h1", text: "Déménager mon Cozy"))
      |> take_screenshot(name: "intro_fr_#{suffix}")
    end)
  end
end
