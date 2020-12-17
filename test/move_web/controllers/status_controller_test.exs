defmodule MoveWeb.PageControllerTest do
  use MoveWeb.ConnCase

  test "GET /status", %{conn: conn} do
    conn = get(conn, "/status")
    assert json_response(conn, 200) == %{"status" => "OK"}
  end
end
