defmodule MoveWeb.Features.InstancePageTest do
  use MoveWeb.FeatureCase, async: true

  test "select a Cozy page can be displayed" do
    for_session(fn session, suffix ->
      session
      |> visit("/en/target/select")
      |> assert_has(Query.css("h1", text: "Select a Cozy"))
      |> take_screenshot(name: "cozy_select_#{suffix}")
    end)
  end

  test "create a new Cozy page can be displayed" do
    for_session(fn session, suffix ->
      session
      |> visit("/en/target/add")
      |> assert_has(Query.css("h1", text: "Create a new Cozy"))
      |> take_screenshot(name: "cozy_add_#{suffix}")
    end)
  end

  test "enter your Cozy address page can be displayed" do
    for_session(fn session, suffix ->
      session
      |> visit("/en/target/edit")
      |> assert_has(Query.css("h1", text: "Enter your Cozy address"))
      |> take_screenshot(name: "cozy_edit_#{suffix}")
    end)
  end
end
