defmodule GoBarber.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias GoBarber.Schedules.Appointment

  @possible_roles ~w(customer provider)

  @required_attrs ~w(name email user_role)a
  @optional_attrs ~w(avatar)a

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field :name, :string
    field :email, :string
    field :avatar, :string
    field :user_role, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    has_many :appointments_as_customer, Appointment, foreign_key: :customer_id
    has_many :appointments_as_provider, Appointment, foreign_key: :provider_id

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  def registration_changeset(user, attrs) do
    user
    |> changeset(attrs)
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 8)
    |> validate_inclusion(:user_role, @possible_roles)
    |> put_pass_hash()
  end

  defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: pass}} = changeset) do
    change(changeset, Argon2.add_hash(pass))
  end

  defp put_pass_hash(invalid_changeset), do: invalid_changeset
end
