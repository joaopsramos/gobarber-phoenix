defmodule GoBarber.Repo.Migrations.AddAvatarAndUserRoleToUsers do
  use Ecto.Migration

  def change do
    alter table "users" do
      add :avatar, :string
      add :user_role, :string
    end

    create constraint(
      "users",
      :user_role_must_be_customer_or_provider,
      check: "user_role = 'customer' OR user_role = 'provider'"
    )
  end
end
