defmodule GoBarber.Schedules.Appointment do
  use Ecto.Schema
  import Ecto.Changeset
  alias GoBarber.Accounts.User

  @required_attrs ~w(date)a
  @optional_attrs ~w(customer_id provider_id)a

  @foreign_key_type :binary_id
  schema "appointments" do
    field :date, :utc_datetime

    belongs_to :customer, User
    belongs_to :provider, User

    timestamps()
  end

  def changeset(appointment, attrs) do
    appointment
    |> cast(attrs, @required_attrs ++ @optional_attrs)
    |> validate_required(@required_attrs)
    |> validate_hour()
    |> validate_past_date()
    |> foreign_key_constraint(:provider_id)
  end

  defp validate_hour(
         %Ecto.Changeset{
           valid?: true,
           changes: %{date: %{hour: hour}}
         } = changeset
       ) do
    if hour < 8 || hour > 17 do
      add_error(changeset, :date, "hour must be between 8 and 17")
    else
      changeset
    end
  end

  defp validate_hour(invalid_changeset), do: invalid_changeset

  defp validate_past_date(
         %Ecto.Changeset{
           valid?: true,
           changes: %{date: appointment_date}
         } = changeset
       ) do
    current_date = datetime_module().utc_now()

    if DateTime.compare(appointment_date, current_date) == :lt do
      raise "date can't be a past date"
    else
      changeset
    end
  end

  defp validate_past_date(invalid_changeset), do: invalid_changeset

  defp datetime_module() do
    Application.get_env(:go_barber, :datetime)
  end
end
