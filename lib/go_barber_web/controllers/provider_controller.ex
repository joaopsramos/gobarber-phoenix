defmodule GoBarberWeb.ProviderController do
  use GoBarberWeb, :controller

  def index(conn, _params) do
    redirect(conn, to: Routes.provider_dashboard_path(conn, :index))
  end
end
