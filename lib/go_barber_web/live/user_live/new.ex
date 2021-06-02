defmodule GoBarberWeb.UserLive.New do
  use GoBarberWeb, :live_view

  alias GoBarber.Accounts
  alias GoBarber.Accounts.User

  def render(assigns), do: Phoenix.View.render(GoBarberWeb.UserView, "new.html", assigns)

  def mount(_params, session, socket) do
    changeset = session["changeset"] || Accounts.change_registration(%User{}, %{})
    {:ok, assign(socket, changeset: changeset, user_role: "customer")}
  end

  def handle_event("change", %{"user" => user_params}, socket) do
    changeset = User.registration_changeset(%User{}, Map.delete(user_params, "password"))

    {:noreply, assign(socket, changeset: changeset, user_role: user_params["user_role"])}
  end
end
