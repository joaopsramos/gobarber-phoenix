defmodule GoBarber.Accounts do
  alias GoBarber.Repo
  alias GoBarber.Accounts.User

  def authenticate_user_by_email_password(email, pass) do
    user = get_user_by(email: email)

    cond do
      user && Argon2.verify_pass(pass, user.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Argon2.no_user_verify()
        {:error, :not_found}
    end
  end

  def change_registration(%User{} = user, params) do
    User.registration_changeset(user, params)
  end

  def get_user(id) do
    Repo.get(User, id)
  end

  def get_user_by(params) do
    Repo.get_by(User, params)
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_avatar(user, avatar) do
    user
    |> User.avatar_changeset(%{avatar: avatar})
    |> Repo.update()
  end

  def update_profile(user, attrs) do
    user
    |> User.profile_changeset(attrs)
    |> Repo.update()
  end

  def profile_changeset(user, attrs \\ %{}) do
    User.profile_changeset(user, attrs)
  end

  def update_user_password(user, password, attrs) do
    user
    |> User.password_changeset(attrs)
    |> User.validate_current_password(password)
    |> Repo.update()
  end
end
