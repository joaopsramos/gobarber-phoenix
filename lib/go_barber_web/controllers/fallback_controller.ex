defmodule GoBarberWeb.FallbackController do
  use GoBarberWeb, :controller

  def call(conn, {:error, reason, status_code}),
    do: render_error(conn, reason, status_code)

  def call(conn, {:error, reason}) do
    render_error(conn, reason, 400)
  end

  defp render_error(conn, reason, status_code) do
    conn
    |> put_status(status_code)
    |> put_view(GoBarberWeb.ErrorView)
    |> render("error.json", reason: reason)
  end
end
