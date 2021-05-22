defmodule GoBarberWeb.API.UserView do
  use GoBarberWeb, :view

  def render("create.json", %{user: user}) do
    serialize(user)
  end

  defp serialize(user) do
    fields = ~w(id name email)

    Map.take(user, fields)
  end
end
