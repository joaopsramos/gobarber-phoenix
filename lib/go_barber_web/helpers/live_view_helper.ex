defmodule GoBarberWeb.Helpers.LiveViewHelper do
  def current_user(%Phoenix.LiveView.Socket{assigns: assigns}), do: assigns.current_user
end
