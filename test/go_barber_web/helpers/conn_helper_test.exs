defmodule GoBarberWeb.ConnHelperTest do
  use GoBarberWeb.ConnCase, async: true
  alias GoBarberWeb.Helpers.ConnHelper

  setup %{conn: conn} do
    user = user_fixture(email: "current@user.com")
    conn = assign(conn, :current_user, user)

    {:ok, conn: conn}
  end

  test "current_user/1 returns the current user", %{conn: conn} do
    current_user = ConnHelper.current_user(conn)

    assert current_user.email == "current@user.com"
  end
end
