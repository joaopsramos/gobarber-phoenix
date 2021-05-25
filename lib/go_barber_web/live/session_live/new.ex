defmodule GoBarberWeb.SessionLive.New do
  use GoBarberWeb, :live_view

  alias GoBarberWeb.ComponentLive

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
