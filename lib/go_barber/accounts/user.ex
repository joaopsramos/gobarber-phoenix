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

  def profile_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unsafe_validate_unique(:email, GoBarber.Repo)
    |> unique_constraint(:email)
  end

  def avatar_changeset(user, avatar) do
    user
    |> cast(avatar, [:avatar])
    |> validate_required([:avatar])
  end

  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_confirmation(:password)
    |> validate_length(:password, min: 8)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:password_hash, Argon2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  defp valid_password?(%GoBarber.Accounts.User{password_hash: password_hash}, password)
       when is_binary(password) and byte_size(password) > 0 do
    Argon2.verify_pass(password, password_hash)
  end

  defp valid_password?(_, _) do
    Argon2.no_user_verify()
    false
  end
end
