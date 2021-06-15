defmodule GoBarberWeb.ComponentLive.Calendar do
  use GoBarberWeb, :live_component
  use Timex

  alias GoBarberWeb.ComponentLive

  def mount(socket) do
    current_date = Date.utc_today()

    assigns = [
      current_date: current_date,
      week_days: week_days()
    ]

    {:ok, assign(socket, assigns)}
  end

  def update(
        %{current_date: current_date, target: target} = default_assigns,
        socket
      ) do
    disabled_days = default_assigns[:disabled_days] || []
    unavailable_dates = build_unavailable_dates(disabled_days, current_date)

    week_rows = week_rows(current_date, unavailable_dates)

    assigns = [
      target: target,
      current_date: update_current_date_if_unavailable(current_date, week_rows),
      week_rows: week_rows
    ]

    {:ok, assign(socket, assigns)}
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

  defp update_current_date_if_unavailable(current_date, week_rows) do
    dates = List.flatten(week_rows)

    if is_available(current_date, dates) do
      current_date
    else
      current_date
    end
  end

  defp is_available(current_date, dates) do
    %{available: available} =
      Enum.find(dates, fn %{date: date} ->
        Date.compare(current_date, date) == :eq
      end)

    available
  end
end
