defmodule GoBarber.TestHelpers do
  alias Ecto.Multi
  alias GoBarber.{Accounts, Schedules, Repo}
  alias GoBarber.Schedules.Appointment

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

  def appointment_fixture(provider_id, attrs \\ %{}) do
    customer = attrs[:customer] || user_fixture()

    attrs =
      Enum.into(attrs, %{
        date: attrs[:date] || ~U[2021-01-01 08:00:00.000000Z],
        provider_id: provider_id
      })

    {:ok, appointment} = Schedules.create_appointment(customer, attrs)

    appointment
  end

  def create_appointments_for_a_day(provider_id, year, month, day) do
    %{id: customer_id} = user_fixture()

    base_date = Date.new!(year, month, day)

    Schedules.hours_range()
    |> Enum.reduce(Multi.new(), fn hour, multi ->
      date = DateTime.new!(base_date, Time.new!(hour, 0, 0))

      changeset =
        Schedules.change_appointment(%Appointment{}, %{
          date: date,
          provider_id: provider_id,
          customer_id: customer_id
        })

      Multi.insert(multi, hour, changeset)
    end)
    |> Repo.transaction()
  end
end
