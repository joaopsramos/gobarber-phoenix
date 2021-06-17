defmodule GoBarberWeb.CustomerLive.Appointments.New do
  use GoBarberWeb, :live_view

  alias GoBarber.Accounts
  alias GoBarber.Schedules
  alias GoBarber.Schedules.Appointment

  def render(assigns),
    do: Phoenix.View.render(GoBarberWeb.Customer.AppointmentsView, "new.html", assigns)

  def mount(_params, %{"user_id" => user_id}, socket) do
    providers = get_providers()
    default_provider_id = List.first(providers)[:id]
    initial_date = Date.utc_today()

    horaries = build_horaries(default_provider_id, initial_date)

    default_hour = get_first_hour(horaries)

    changeset = Schedules.change_appointment(%Appointment{}, %{})

    assigns = [
      providers: providers,
      changeset: changeset,
      selected_provider: default_provider_id,
      horaries: horaries,
      default_hour: default_hour,
      selected_date: initial_date
    ]

    {:ok,
     socket
     |> assign_new(:current_user, fn -> Accounts.get_user(user_id) end)
     |> assign(assigns)}
  end

  def handle_event("change_provider", %{"provider_id" => provider_id}, socket) do
    horaries = build_horaries(provider_id, socket.assigns.selected_date)
    default_hour = get_first_hour(horaries)

    assigns = [
      default_hour: default_hour,
      horaries: horaries,
      selected_provider: provider_id
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "submit",
        %{
          "appointment" => %{
            "date" => date,
            "hour" => hour,
            "provider_id" => provider_id
          }
        },
        socket
      ) do
    customer = socket.assigns.current_user
    date = Date.from_iso8601!(date)
    time = hour |> String.to_integer() |> Time.new!(0, 0)
    datetime = DateTime.new!(date, time)

    case Schedules.create_appointment(customer, %{date: datetime, provider_id: provider_id}) do
      {:ok, _appointment} ->
        {:noreply, push_redirect(socket, to: Routes.customer_dashboard_path(socket, :index))}

      {:error, _reason} ->
        {:noreply, socket}
    end
  end

  def handle_info({"date_changed", _, date}, socket) do
    provider_id = socket.assigns.selected_provider
    horaries = build_horaries(provider_id, date)
    default_hour = get_first_hour(horaries)

    assigns = [
      selected_date: date,
      default_hour: default_hour,
      horaries: horaries
    ]

    {:noreply, assign(socket, assigns)}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  defp get_providers() do
    Enum.map(Schedules.list_providers(), fn provider ->
      Map.take(provider, [:id, :name, :avatar])
    end)
  end

  defp build_horaries(provider_id, date) do
    day_availability =
      Schedules.list_provider_day_availability(
        provider_id,
        date
      )

    build_horaries(day_availability)
  end

  defp build_horaries(day_availability) do
    acc = [%{label: "Morning", hours: []}, %{label: "Afternoon", hours: []}]

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
