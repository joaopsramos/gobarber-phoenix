defmodule GoBarberWeb.SessionController do
  use GoBarberWeb, :controller

  alias GoBarber.Accounts
  alias GoBarberWeb.Auth

  def create(conn, %{"session" => %{"email" => email, "password" => pass}}) do
    case Accounts.authenticate_user_by_email_password(email, pass) do
      {:ok, user} ->
        conn
        |> Auth.login(user)
        |> redirect(to: "/dashboard")

      {:error, _} ->
        conn
        |> redirect(to: "/signin")
    end
  end

  def delete(conn, _params) do
    conn
    |> Auth.logout()
    |> redirect(to: "/signin")
  end
end
