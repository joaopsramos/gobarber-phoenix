defmodule GoBarberWeb.UserController do
  use GoBarberWeb, :controller

  import Phoenix.LiveView.Controller

  alias GoBarber.Accounts
  alias GoBarberWeb.Auth

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> redirect_by_user_role(user)

      {:error, changeset} ->
        live_render(conn, GoBarberWeb.UserLive.New,
          session: %{"changeset" => changeset, "user_role" => user_params["user_role"]}
        )
    end
  end
end
