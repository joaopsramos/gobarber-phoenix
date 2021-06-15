defmodule GoBarberWeb.CustomerLive.Dashboard do
  use GoBarberWeb, :live_view

  alias GoBarber.Accounts
  alias GoBarber.Schedules

  def render(assigns),
    do: Phoenix.View.render(GoBarberWeb.Customer.DashboardView, "index.html", assigns)

  def mount(_params, %{"user_id" => user_id}, socket) do
    appointments = Schedules.list_customer_appointments(user_id)

    {:ok,
     socket
     |> assign_new(:current_user, fn -> Accounts.get_user(user_id) end)
     |> assign(appointments: appointments)}
  end
end
