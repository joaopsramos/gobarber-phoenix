defmodule GoBarber.DateProvider.Gobarber do
  @behaviour GoBarber.DateProvider

  @impl true
  def utc_now() do
    DateTime.utc_now()
  end

  @impl true
  def utc_today() do
    Date.utc_today()
  end
end
