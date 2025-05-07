defmodule MoveWeb.Features.MovePageTest do
  use MoveWeb.FeatureCase, async: true

  test "move my Cozy page can be displayed with no instances" do
    for_session(fn session, suffix ->
      session
      |> visit("/en/instances")
      |> assert_has(Query.css("h1", text: "Move my Twake"))
      |> take_screenshot(name: "move_empty_#{suffix}")
    end)
  end

  test "move my Cozy page can show the quota error" do
    for_session(fn session, suffix ->
      session
      |> visit("/test/source?disk=9876543210")
      |> visit("/test/target?quota=123456789")
      |> visit("/en/instances")
      |> assert_has(Query.css(".u-error", count: 4))
      |> take_screenshot(name: "move_error_#{suffix}")
    end)
  end

  test "instances can be swapped on the move my Cozy page" do
    for_session(fn session, suffix ->
      session
      |> visit("/test/source")
      |> visit("/test/target")
      |> visit("/en/instances")
      |> click(Query.button("Switch"))
      |> assert_has(Query.button("Switch"))
      |> take_screenshot(name: "move_swapped_#{suffix}")
    end)
  end

  test "a confirmation modal can be opened on the move my Cozy page" do
    for_session(fn session, suffix ->
      session
      |> visit("/test/source")
      |> visit("/test/target")
      |> visit("/en/instances")
      |> click(Query.button("Start the move!"))
      |> sleep(1000)
      |> assert_has(Query.button("Overwrite the data"))
      |> take_screenshot(name: "move_modal_#{suffix}")
    end)
  end
end
