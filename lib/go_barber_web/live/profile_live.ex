defmodule GoBarberWeb.ProfileLive do
  use GoBarberWeb, :live_view

  alias GoBarber.Accounts
  alias GoBarberWeb.Router.Helpers, as: Routes

  def render(assigns), do: Phoenix.View.render(GoBarberWeb.ProfileView, "index.html", assigns)

  def mount(_params, %{"user_id" => user_id}, socket) do
    user = Accounts.get_user(user_id)

    assigns = [
      changeset: Accounts.User.changeset(user, %{}),
      uploaded_files: []
    ]

    {:ok,
     socket
     |> assign_new(:current_user, fn -> Accounts.get_user(user_id) end)
     |> assign(assigns)
     |> allow_upload(:avatar,
       accept: ~w(.jpg .jpeg),
       progress: &handle_avatar/3,
       auto_upload: true
     )}
  end

  defp handle_avatar(:avatar, entry, socket) do
    if entry.done? do
      uploaded_file =
        consume_uploaded_entry(socket, entry, fn %{path: path} ->
          [file_type | _] = MIME.extensions(entry.client_type)
          dest = Path.join(["tmp", "#{Path.basename(path)}.#{file_type}"])
          File.cp!(path, dest)

          dest
        end)

      {:ok, updated_user} = Accounts.update_avatar(current_user(socket), uploaded_file)

      {:noreply, assign(socket, current_user: updated_user)}
    else
      {:noreply, socket}
    end
  end

  def handle_event("change_avatar", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", %{"user" => user_params}, socket) do
    current_user = socket.assigns.current_user

    change_password? =
      Enum.any?(user_params, fn {param, value} ->
        param in ~w(current_password new_password new_password_confirmation) && value != ""
      end)

    if change_password? do
      user_params =
        change_user_params_keys(user_params, [
          {"new_password", "password"},
          {"new_password_confirmation", "password_confirmation"}
        ])

      current_user
      |> Accounts.profile_changeset(user_params)
      |> Accounts.update_user_password(user_params["current_password"], user_params)
    else
      Accounts.update_profile(current_user, user_params)
    end

    {:noreply, push_redirect(socket, to: Routes.profile_path(socket, :index))}
  end

  defp change_user_params_keys(user_params, keys_to_update) do
    Enum.reduce(keys_to_update, user_params, fn {old_key, new_key}, user_params ->
      case Map.pop(user_params, old_key) do
        {nil, map} -> map
        {value, map} -> Map.put(map, new_key, value)
      end
    end)
  end
end
