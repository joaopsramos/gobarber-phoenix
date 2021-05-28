defmodule GoBarber.TestHelpers do
  alias GoBarber.Accounts

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        name: "some name",
        user_role: attrs[:user_role] || "customer",
        email: "user#{System.unique_integer([:positive])}@email.com",
        password: attrs[:password] || "some password"
      })
      |> Accounts.register_user()

    user
  end
end
