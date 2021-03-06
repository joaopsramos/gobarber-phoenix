defmodule GoBarber.Schedules do
  import Ecto.Query

  alias GoBarber.Repo
  alias GoBarber.Accounts
  alias GoBarber.Schedules.Appointment

  @scheduling_time 1
  @start_hour 8
  @end_hour 18

  def change_appointment(%Appointment{} = appointment, params \\ %{}) do
    Appointment.changeset(appointment, params)
  end

  def create_appointment(%Accounts.User{} = customer, attrs \\ %{}) do
    %Appointment{}
    |> Appointment.changeset(attrs)
    |> validate_unique_date()
    |> validate_ids_not_equal(customer)
    |> Ecto.Changeset.put_assoc(:customer, customer)
    |> Repo.insert()
  end

  def get_appointment_by(params) do
    Repo.get_by(Appointment, params)
  end

  def get_schedules_constants() do
    %{
      scheduling_time: @scheduling_time,
      start_hour: @start_hour,
      end_hour: @end_hour
    }
  end

  def list_customer_appointments(customer_id) do
    current_date = DateTime.utc_now()

    from(a in Appointment,
      where:
        a.customer_id == ^customer_id and
          a.date > ^current_date,
      order_by: [asc: a.date],
      preload: :provider
    )
    |> Repo.all()
  end

  def list_all_in_month_from_provider(provider_id, date) do
    start_of_month = Date.beginning_of_month(date)
    default_time = Time.new!(1, 0, 0)

    from(a in Appointment,
      where:
        a.provider_id == ^provider_id and
          a.date > ^DateTime.new!(start_of_month, default_time) and
          a.date < datetime_add(^DateTime.new!(start_of_month, default_time), 1, "month")
    )
    |> Repo.all()
  end

  def list_all_in_day_from_provider(provider_id, date) do
    default_time = Time.new!(1, 0, 0)

    customer_query = from a in Accounts.User, select: %{name: a.name, avatar: a.avatar}

    from(a in Appointment,
      where:
        a.provider_id == ^provider_id and
          a.date > ^DateTime.new!(date, default_time) and
          a.date < datetime_add(^DateTime.new!(date, default_time), 1, "day"),
      order_by: [asc: a.date],
      preload: [customer: ^customer_query]
    )
    |> Repo.all()
  end

  def list_providers() do
    from(u in Accounts.User, where: u.user_role == "provider")
    |> Repo.all()
  end

  def list_provider_day_availability(provider_id, date) do
    datetime = DateTime.new!(date, Time.new!(0, 0, 0))

    appointments =
      from(a in Appointment,
        where:
          a.provider_id == ^provider_id and
            a.date >= ^datetime and
            a.date < datetime_add(^datetime, 1, "day")
      )
      |> Repo.all()

    day_availability(datetime, appointments)
  end

  def list_provider_month_availability(provider_id, date) do
    list_provider_month_availability(provider_id, date.year, date.month)
  end

  def list_provider_month_availability(provider_id, year, month) do
    date = DateTime.new!(Date.new!(year, month, 1), Time.new!(0, 0, 0))

    appointments =
      Repo.all(
        from a in Appointment,
          where:
            a.provider_id == ^provider_id and
              a.date >= ^date and
              a.date < datetime_add(^date, 1, "month")
      )

    days = Calendar.ISO.days_in_month(year, month)

    1..days
    |> Enum.map(fn day ->
      availability = day_availability(Date.new!(year, month, day), appointments)

      %{
        day: day,
        available: Enum.any?(availability, & &1.available)
      }
    end)
  end

  defp day_availability(date, appointments) do
    date_to_compare = Date.compare(date, GoBarber.DateProvider.utc_today())

    hours_range()
    |> Enum.map(fn hour ->
      found? =
        Enum.find(appointments, fn appointment ->
          Date.compare(date, appointment.date) == :eq && appointment.date.hour == hour
        end)

      valid_hour? =
        cond do
          date_to_compare == :eq && hour > GoBarber.DateProvider.utc_now().hour -> true
          date_to_compare == :gt -> true
          true -> false
        end

      %{
        hour: hour,
        available: !found? && valid_hour?
      }
    end)
  end

  def hours_range() do
    @start_hour..(@end_hour - @scheduling_time)
  end

  defp validate_ids_not_equal(
         %Ecto.Changeset{valid?: true, changes: %{provider_id: provider_id}} = changeset,
         customer
       ) do
    if customer.id == provider_id do
      raise "you can't create an appointment with yourself"
    else
      changeset
    end
  end

  defp validate_ids_not_equal(invalid_changeset, _), do: invalid_changeset

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
