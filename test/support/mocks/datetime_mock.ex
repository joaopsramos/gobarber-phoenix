defmodule GoBarber.Mocks.DateTimeMock do
  @behaviour GoBarber.Behaviours.DateTime

  def set_date(%DateTime{} = date) do
    Process.put(self(), date)
  end

  @impl true
  def utc_now() do
    Process.get(self(), DateTime.utc_now())
  end
end
