defmodule GoBarber.Schedules.Appointment do
  use Ecto.Schema
  import Ecto.Changeset
  alias GoBarber.Accounts.User

  @required_attrs ~w(date provider_id customer_id)a

  @foreign_key_type :binary_id
  schema "appointments" do
    field :date, :utc_datetime
    belongs_to :customer, User
    belongs_to :provider, User

    timestamps()
  end

  def changeset(appointment, attrs) do
    appointment
    |> cast(attrs, @required_attrs)
    |> validate_required(@required_attrs)
    |> foreign_key_constraint(:provider_id)
  end
end
