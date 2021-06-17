defmodule GoBarberWeb.ComponentLive.Calendar do
  use GoBarberWeb, :live_component
  use Timex

  def mount(socket) do
    current_date = Date.utc_today()

    assigns = [
      current_date: current_date,
      week_days: week_days()
    ]

    {:ok, assign(socket, assigns)}
  end

  def update(default_assigns, socket) do
    current_date =
      default_assigns[:current_date] || socket.assigns[:current_date] || Date.utc_today()

    disabled_days = default_assigns[:disabled_days] || []

    unavailable_dates = build_unavailable_dates(disabled_days, current_date)
    week_rows = week_rows(current_date, unavailable_dates)

    assigns = [
      target: default_assigns[:target] || socket.assigns.myself,
      current_date: current_date,
      week_rows: week_rows,
      notify_date_change: default_assigns[:notify_date_change]
    ]

    {:ok, assign(socket, assigns)}
  end

  def handle_event("change_day", %{"available" => available, "date" => date}, socket) do
    if available == "true" do
      date = Date.from_iso8601!(date)
      notify(:day, date, socket)

      {:noreply, assign(socket, current_date: date)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("prev-month", %{"date" => date}, socket) do
    date = Date.from_iso8601!(date)
    assigns = change_month(date, :prev, socket)

    {:noreply, assign(socket, assigns)}
  end

  def handle_event("next-month", %{"date" => date}, socket) do
    date = Date.from_iso8601!(date)
    assigns = change_month(date, :next, socket)

    {:noreply, assign(socket, assigns)}
  end

  defp build_unavailable_dates(days, %{year: year, month: month}) do
    Enum.map(days, fn day -> Date.new!(year, month, day) end)
  end

  defp week_days() do
    Enum.map(1..7, fn day_n ->
      letter = day_n |> Timex.day_shortname() |> String.first()

      %{number: day_n, letter: letter}
    end)
  end

  defp week_rows(current_date, unavailable_dates) do
    first =
      current_date
      |> Date.beginning_of_month()
      |> Date.beginning_of_week()

    last =
      current_date
      |> Date.end_of_month()
      |> Date.end_of_week()

    Date.range(first, last)
    |> Enum.map(fn date ->
      unavailable =
        Enum.find_value(unavailable_dates, false, fn date_to_compare ->
          Date.compare(date, date_to_compare) == :eq
        end)

      %{
        date: date,
        available: !unavailable
      }
    end)
    |> Enum.chunk_every(7)
  end

  defp change_month(date, prev_or_next, socket) do
    new_date =
      case prev_or_next do
        :prev -> Timex.shift(date, months: -1)
        :next -> Timex.shift(date, months: 1)
      end

    week_rows = week_rows(new_date, [])

    notify(:month, new_date, socket)

    [
      current_date: new_date,
      week_rows: week_rows
    ]
  end

  defp notify(period, date, socket) do
    notify_date_change = socket.assigns.notify_date_change

    if notify_date_change do
      send(self(), {"date_changed", period, date})
    end
  end

  # defp update_current_date_if_unavailable(current_date, week_rows) do
  #   dates = List.flatten(week_rows)

  #   if is_available(current_date, dates) do
  #     current_date
  #   else
  #     current_date
  #   end
  # end

  # defp is_available(current_date, dates) do
  #   %{available: available} =
  #     Enum.find(dates, fn %{date: date} ->
  #       Date.compare(current_date, date) == :eq
  #     end)

  #   available
  # end
end
