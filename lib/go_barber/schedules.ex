defmodule GoBarber.Schedules do
  import Ecto.Query

  alias GoBarber.Repo
  alias GoBarber.Accounts
  alias GoBarber.Schedules.Appointment

  @scheduling_time 1
  @start_hour 8
  @end_hour 18

  def create_appointment(
        %{
          provider: %Accounts.User{} = customer,
          customer: %Accounts.User{} = provider
        },
        attrs \\ %{}
      ) do
    %Appointment{}
    |> Appointment.changeset(attrs)
    |> validate_unique_date()
    |> Ecto.Changeset.put_assoc(:customer, customer)
    |> Ecto.Changeset.put_assoc(:provider, provider)
    |> Repo.insert()
  end

  def get_appointment_by(params) do
    Repo.get_by(Appointment, params)
  end

  def provider_month_availability(provider_id, year, month) do
    %{appointments_as_provider: appointments} =
      from(p in Accounts.User, where: p.id == ^provider_id, preload: :appointments_as_provider)
      |> Repo.one()

    days = Calendar.ISO.days_in_month(year, month)

    1..days
    |> Enum.map(fn day ->
      day_availability =
        @start_hour..(@end_hour - @scheduling_time)
        |> Enum.map(fn hour ->
          Enum.any?(appointments, fn %{date: date} ->
            Date.compare(date, Date.new!(year, month, day)) == :eq && date.hour == hour
          end)
        end)

      %{
        day: day,
        available: !Enum.all?(day_availability)
      }
    end)
  end

  def providers() do
    Accounts.get_user_by(user_role: "provider")
    |> Repo.all()
  end

  defp validate_unique_date(
         %Ecto.Changeset{
           valid?: true,
           changes: %{date: date}
         } = changeset
       ) do
    appointment_exists = get_appointment_by(date: date)

    if appointment_exists do
      raise "there is already another appointment for that date"
    else
      changeset
    end
  end

  defp validate_unique_date(invalid_changeset), do: invalid_changeset
end
