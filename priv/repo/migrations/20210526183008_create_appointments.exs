defmodule GoBarber.Repo.Migrations.CreateAppointments do
  use Ecto.Migration

  def change do
    create table "appointments" do
      add :date, :utc_datetime
      add :provider_id,
          references(:users,
            type: :binary_id,
            on_delete: :nilify_all,
            on_update: :update_all
          ),
          null: false
      add :customer_id,
          references(:users,
            type: :binary_id,
            on_delete: :nilify_all,
            on_update: :update_all
          ),
          null: false

      timestamps()
    end

    create index(:appointments, [:provider_id])
    create index(:appointments, [:customer_id])
  end
end
