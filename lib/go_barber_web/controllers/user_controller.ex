defmodule GoBarberWeb.UserController do
  use GoBarberWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html")
  end
end
