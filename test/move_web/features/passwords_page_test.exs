defmodule MoveWeb.Features.PasswordsPageTest do
  use MoveWeb.FeatureCase, async: true

  test "move my Cozy page can show the quota error" do
    for_session(fn session, suffix ->
      session
      |> visit("/test/source?vault=true")
      |> visit("/test/target")
      |> visit("/en/passwords")
      |> assert_has(Query.css("h1", text: "Export your passwords"))
      |> take_screenshot(name: "passwords_#{suffix}")
    end)
  end
end
