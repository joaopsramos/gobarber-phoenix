defmodule GoBarberWeb.Provider.DashboardController do
  use GoBarberWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
