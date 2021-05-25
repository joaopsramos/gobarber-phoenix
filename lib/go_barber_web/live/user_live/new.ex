defmodule GoBarberWeb.UserLive.New do
  use GoBarberWeb, :live_view

  alias GoBarber.Accounts
  alias GoBarber.Accounts.User
  alias GoBarberWeb.ComponentLive

  def mount(_params, _session, socket) do
    changeset = Accounts.change_registration(%User{}, %{})
    {:ok, assign(socket, changeset: changeset, focused: false, value: "")}
  end

  def handle_event("submit", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, _user} ->
        {:noreply,
         socket
         |> put_flash(:info, "Você foi cadastrado")
         |> redirect(to: Routes.page_path(socket, :index))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
