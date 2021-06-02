defmodule GoBarberWeb.UserController do
  use GoBarberWeb, :controller

  alias GoBarber.Accounts
  alias GoBarber.Accounts.User
  alias GoBarberWeb.Auth

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> redirect_by_user_role(user)

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def new(conn, _params) do
    changeset = Accounts.change_registration(%User{}, %{})
    render(conn, "new.html", changeset: changeset)
  end
end
