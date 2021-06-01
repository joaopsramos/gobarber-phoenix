defmodule GoBarberWeb.CustomerController do
  use GoBarberWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.customer_dashboard_path(conn, :index))
  end
end
