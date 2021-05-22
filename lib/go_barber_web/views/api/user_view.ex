defmodule GoBarberWeb.API.UserView do
  use GoBarberWeb, :view

  def render("create.json", %{user: user}) do
    render_one(user, __MODULE__, "show.json")
  end

  def render("show.json", %{user: user}) do
    fields = ~w(id name email)a

    Map.take(user, fields)
  end
end
