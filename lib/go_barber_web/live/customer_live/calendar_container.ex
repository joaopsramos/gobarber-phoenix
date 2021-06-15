defmodule GoBarberWeb.CustomerLive.CalendarContainer do
  use GoBarberWeb, :live_component

  alias GoBarber.Schedules

  def render(assigns) do
    ~L"""
    <div>
      <%= live_component @socket, ComponentLive.Calendar,
            id: "calendar",
            current_date: @selected_date,
            disabled_days: @disabled_days,
            target: @myself
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

  def handle_event("pick-date", %{"available" => "false"}, socket) do
    {:noreply, socket}
  end

  def handle_event("pick-date", %{"date" => date}, socket) do
    new_date = Date.from_iso8601!(date)

    assigns = [
      selected_date: new_date
    ]

    update_date(new_date)
    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "prev-month",
        %{"date" => date},
        %{assigns: %{provider_id: provider_id}} = socket
      ) do
    assigns = change_month(date, provider_id, :prev)

    update_date(assigns[:selected_date])
    {:noreply, assign(socket, assigns)}
  end

  def handle_event(
        "next-month",
        %{"date" => date},
        %{assigns: %{provider_id: provider_id}} = socket
      ) do
    assigns = change_month(date, provider_id, :next)

    update_date(assigns[:selected_date])
    {:noreply, assign(socket, assigns)}
  end

  defp update_date(date) do
    send(self(), {:update_date, date})
  end

  defp get_disabled_days(provider_id, date) do
    provider_id
    |> Schedules.list_provider_month_availability(date)
    |> Enum.flat_map(fn %{available: available, day: day} ->
      if available, do: [], else: [day]
    end)
  end

  defp change_month(date, provider_id, prev_or_next) do
    new_date = get_next_prev_month(date, prev_or_next)
    disabled_days = get_disabled_days(provider_id, new_date)

    [
      selected_date: new_date,
      disabled_days: disabled_days
    ]
  end

  defp get_next_prev_month(date, prev_or_next) when is_binary(date) do
    date = Date.from_iso8601!(date)

    case prev_or_next do
      :prev -> Timex.shift(date, months: -1)
      :next -> Timex.shift(date, months: 1)
    end
  end
end
