defmodule GoBarberWeb.CustomerLive.Dashboard do
  use GoBarberWeb, :live_view

  alias GoBarber.Accounts

  def render(assigns),
    do: Phoenix.View.render(GoBarberWeb.Customer.DashboardView, "index.html", assigns)

  def mount(_params, %{"user_id" => user_id}, socket) do
    {:ok, assign_new(socket, :current_user, fn -> Accounts.get_user(user_id) end)}
  end
end
