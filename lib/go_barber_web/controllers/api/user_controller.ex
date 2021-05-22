defmodule GoBarberWeb.API.UserController do
  use GoBarberWeb, :controller

  alias GoBarber.Accounts

  action_fallback GoBarberWeb.FallbackController

  def create(conn, user_params) do
    with {:ok, user} <- Accounts.register_user(user_params) do
      conn
      |> put_status(201)
      |> render("create.json", user: user)
    end
  end
end
