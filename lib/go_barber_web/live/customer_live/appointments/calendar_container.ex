defmodule GoBarberWeb.CustomerLive.Appointments.CalendarContainer do
  use GoBarberWeb, :live_component

  alias GoBarber.Schedules

  def render(assigns) do
    ~L"""
    <div>
      <%= live_component @socket, ComponentLive.Calendar,
            id: "calendar",
            disabled_days: @disabled_days,
            notify_date_change: true
      %>
    </div>
    """
  end

  def mount(socket) do
    {:ok, socket}
  end

  def update(%{provider_id: provider_id, selected_date: selected_date}, socket) do
    disabled_days = get_disabled_days(provider_id, selected_date)

    assigns = [
      provider_id: provider_id,
      selected_date: selected_date,
      disabled_days: disabled_days
    ]

    {:ok, assign(socket, assigns)}
  end

  defp get_disabled_days(provider_id, date) do
    provider_id
    |> Schedules.list_provider_month_availability(date)
    |> Enum.flat_map(fn %{available: available, day: day} ->
      if available, do: [], else: [day]
    end)
  end
end
