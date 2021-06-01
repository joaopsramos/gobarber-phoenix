defmodule GoBarberWeb.Helpers.ControllerHelpers do
  import Plug.Conn
  import Phoenix.Controller
  import GoBarberWeb.Helpers.ConnHelper

  alias GoBarber.Accounts
  alias GoBarberWeb.Router.Helpers, as: Routes

  def requires_provider(conn, _opts) do
    requires_user_role(conn, :provider)
  end

  def requires_customer(conn, _opts) do
    requires_user_role(conn, :customer)
  end

  defp requires_user_role(conn, required_role) do
    user = current_user(conn)
    user_role = String.to_atom(user.user_role)

    if user_role != required_role do
      redirect_by_user_role(conn, user_role)
    else
      conn
    end
  end

  def redirect_by_user_role(conn, %Accounts.User{} = user) do
    redirect_by_user_role(conn, String.to_atom(user.user_role))
  end

  def redirect_by_user_role(conn, role) do
    case role do
      :provider ->
        conn
        |> redirect(to: Routes.provider_path(conn, :index))
        |> halt()

      :customer ->
        conn
        |> redirect(to: Routes.customer_path(conn, :index))
        |> halt()
    end
  end
end
