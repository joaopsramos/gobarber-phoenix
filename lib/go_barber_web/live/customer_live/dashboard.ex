defmodule GoBarberWeb.CustomerLive.Dashboard do
  use GoBarberWeb, :live_view

  alias GoBarber.Accounts
  alias GoBarber.Schedules
  alias GoBarber.Schedules.Appointment

  def render(assigns),
    do: Phoenix.View.render(GoBarberWeb.Customer.DashboardView, "index.html", assigns)

  def mount(_params, %{"user_id" => user_id}, socket) do
    providers = get_providers()
    default_provider_id = List.first(providers)[:id]

    day_availability =
      Schedules.list_provider_day_availability(default_provider_id, Date.add(Date.utc_today(), 1))

    horaries = build_horaries(day_availability)
    default_hour = get_first_hour(horaries)

    changeset = Schedules.change_appointment(%Appointment{}, %{})

    {:ok,
     socket
     |> assign_new(:current_user, fn -> Accounts.get_user(user_id) end)
     |> assign(
       providers: providers,
       changeset: changeset,
       selected_provider: default_provider_id,
       horaries: horaries,
       default_hour: default_hour
     )}
  end

  defp get_providers() do
    Enum.map(Schedules.list_providers(), fn provider ->
      Map.take(provider, [:id, :name, :avatar])
    end)
  end

  def handle_event("click", %{"provider_id" => provider_id}, socket) do
    {:noreply, assign(socket, selected_provider: provider_id)}
  end

  def handle_event("submit", params, socket) do
    IO.inspect(params)
    {:noreply, socket}
  end

  defp build_horaries(day_availability) do
    acc = [%{label: "Manhã", hours: []}, %{label: "Tarde", hours: []}]

    for %{hour: hour, available: available} <- day_availability, available, reduce: acc do
      [morning, afternoon] ->
        if hour < 12 do
          updated_morning = update_in(morning.hours, &(&1 ++ [hour]))

          [updated_morning, afternoon]
        else
          updated_afternoon = update_in(afternoon.hours, &(&1 ++ [hour]))
          [morning, updated_afternoon]
        end
    end
  end

  defp get_first_hour([morning, afternoon]) do
    List.first(morning.hours) || List.first(afternoon.hours)
  end
end
