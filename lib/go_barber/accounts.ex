defmodule GoBarber.Accounts do
  alias GoBarber.Repo
  alias GoBarber.Accounts.User

  def register_user(attrs) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end
end
