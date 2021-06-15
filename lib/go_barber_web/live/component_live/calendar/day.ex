defmodule GoBarberWeb.ComponentLive.Day do
  use GoBarberWeb, :live_component
  use Timex

  def render(assigns) do
    ~L"""
    <div
      class="py-2.5 px-3 rounded-lg transition-all duration-200
            text-center <%= @day_class %>"
      phx-click="pick-date"
      phx-target="<%= @target %>"
      phx-value-date='<%= Calendar.strftime(@date, "%Y-%m-%d") %>'
      phx-value-available="<%= @available %>"
    >
      <%= Calendar.strftime(@date, "%d") %>
    </div>
    """
  end

  def update(assigns, socket) do
    updated_assigns = [
      target: assigns.target,
      date: assigns.date,
      available: assigns.available,
      day_class: day_class(assigns)
    ]

    {:ok, assign(socket, updated_assigns)}
  end

  defp day_class(assigns) do
    cond do
      current_date?(assigns) -> "bg-orange text-black cursor-pointer"
      other_month?(assigns) -> "hidden"
      !assigns.available -> ""
      true -> "bg-shape text-white cursor-pointer"
    end
  end

  defp current_date?(assigns) do
    Date.compare(assigns.date, assigns.current_date) == :eq
  end

  defp other_month?(assigns) do
    Map.take(assigns.date, [:year, :month]) != Map.take(assigns.current_date, [:year, :month])
  end
end
