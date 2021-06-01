defmodule GoBarberWeb.Helpers.ConnHelper do
  def current_user(%Plug.Conn{assigns: assigns}), do: assigns.current_user
end
