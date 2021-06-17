defmodule GoBarberWeb.ProviderLive.Dashboard do
  use GoBarberWeb, :live_view

  alias GoBarber.Accounts
  alias GoBarber.Schedules

  def render(assigns),
    do: Phoenix.View.render(GoBarberWeb.Provider.DashboardView, "index.html", assigns)

  def mount(_params, %{"user_id" => user_id}, socket) do
    date = Date.utc_today()

    assigns = build_assigns(user_id, date)
    disabled_days = build_disabled_days(user_id, date)

    {:ok,
     socket
     |> assign_new(:current_user, fn -> Accounts.get_user(user_id) end)
     |> assign(assigns ++ [disabled_days: disabled_days])}
  end

  def handle_info({"date_changed", :month, date}, socket) do
    provider_id = socket.assigns.current_user.id

    assigns = build_assigns(provider_id, date)
    disabled_days = build_disabled_days(provider_id, date)

    {:noreply, assign(socket, Keyword.put(assigns, :disabled_days, disabled_days))}
  end

  def handle_info({"date_changed", _, date}, socket) do
    provider_id = socket.assigns.current_user.id

    assigns = build_assigns(provider_id, date)

    {:noreply, assign(socket, assigns)}
  end

  defp build_assigns(provider_id, date) do
    case Schedules.list_all_in_day_from_provider(provider_id, date) do
      [] ->
        [
          current_date: date,
          next_appointment: nil,
          horaries: []
        ]

      [first_appointment | appointments] ->
        [
          current_date: date,
          next_appointment: first_appointment,
          horaries: build_horaries(appointments)
        ]
    end
  end

  def build_disabled_days(provider_id, date) do
    days_with_appointments =
      Schedules.list_all_in_month_from_provider(provider_id, date)
      |> Enum.group_by(& &1.date.day)
      |> Enum.map(fn {key, _value} -> key end)

    1..Date.days_in_month(date)
    |> Enum.map(& &1)
    |> Kernel.--(days_with_appointments)
  end

  defp build_horaries(appointments) do
    acc = [%{label: "Morning", appointments: []}, %{label: "Afternoon", appointments: []}]

    for %{date: date} = appointment <- appointments, reduce: acc do
      [morning, afternoon] ->
        if date.hour < 12 do
          updated_morning = update_in(morning.appointments, &(&1 ++ [appointment]))

          [updated_morning, afternoon]
        else
          updated_afternoon = update_in(afternoon.appointments, &(&1 ++ [appointment]))
          [morning, updated_afternoon]
        end
    end
    |> Enum.reject(&Enum.empty?(&1.appointments))
  end
end
