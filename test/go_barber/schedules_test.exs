defmodule GoBarber.SchedulesTest do
  use GoBarber.DataCase, async: true

  import Hammox

  alias GoBarber.Accounts.User
  alias GoBarber.Schedules
  alias GoBarber.Schedules.Appointment

  setup do
    stub(GoBarber.DateProvider.Mock, :utc_now, fn -> ~U[2021-01-01 00:00:00.000000Z] end)
    stub(GoBarber.DateProvider.Mock, :utc_today, fn -> ~D[2021-01-01] end)

    :ok
  end

  test "list_providers/0 returns all providers" do
    %User{} = user_fixture(%{user_role: "customer"})
    %User{id: id1} = user_fixture(%{user_role: "provider"})

    assert [%User{id: ^id1}] = Schedules.list_providers()

    %User{id: id2} = user_fixture(%{user_role: "provider"})

    assert [%User{id: ^id1}, %User{id: ^id2}] = Schedules.list_providers()
  end

  describe "create_appointment/1" do
    @invalid_attrs %{date: nil, provider_id: nil}

    setup do
      %User{id: provider_id} = user_fixture(%{user_role: "provider"})

      {
        :ok,
        customer:
          user_fixture(%{
            user_role: "customer"
          }),
        valid_attrs: %{
          date: ~U[2022-01-01 08:00:00.000000Z],
          provider_id: provider_id
        }
      }
    end

    test "with valid data create an appointment", %{customer: customer, valid_attrs: valid_attrs} do
      assert {:ok, %Appointment{} = appointment} =
               Schedules.create_appointment(
                 customer,
                 valid_attrs
               )

      assert DateTime.compare(valid_attrs.date, appointment.date) == :eq
    end

    test "with invalid data returns error changeset", %{customer: customer} do
      assert {:error, %Ecto.Changeset{}} =
               Schedules.create_appointment(
                 customer,
                 @invalid_attrs
               )
    end

    test "if hour is not between 08:00 and 17:00 returns error changeset", %{
      customer: customer,
      valid_attrs: %{provider_id: provider_id} = valid_attrs
    } do
      {:error, %Ecto.Changeset{} = changeset} =
        Schedules.create_appointment(customer, %{
          date: ~U[2021-06-01 07:00:00.000000Z],
          provider_id: provider_id
        })

      assert errors_on(changeset)[:date] == ["hour must be between 8 and 17"]

      {:error, %Ecto.Changeset{} = changeset} =
        Schedules.create_appointment(
          customer,
          %{date: ~U[2021-06-01 18:00:00.000000Z], provider_id: provider_id}
        )

      assert errors_on(changeset)[:date] == ["hour must be between 8 and 17"]

      assert {:ok, %Appointment{}} = Schedules.create_appointment(customer, valid_attrs)
    end

    test "if another appointment is already on the same date raises an error", %{
      valid_attrs: valid_attrs,
      customer: customer
    } do
      assert {:ok, %Appointment{}} =
               Schedules.create_appointment(
                 customer,
                 valid_attrs
               )

      assert_raise RuntimeError, "there is already another appointment for that date", fn ->
        Schedules.create_appointment(
          customer,
          valid_attrs
        )
      end
    end

    test "if date is a past date raises an error", %{
      customer: customer,
      valid_attrs: %{provider_id: provider_id}
    } do
      stub(GoBarber.DateProvider.Mock, :utc_now, fn -> ~U[2021-01-02 00:00:00.000000Z] end)

      assert_raise RuntimeError, "date can't be a past date", fn ->
        Schedules.create_appointment(
          customer,
          %{date: ~U[2021-01-01 10:00:00.000000Z], provider_id: provider_id}
        )
      end
    end

    test "the customer and provider id must be different", %{customer: customer} do
      assert_raise RuntimeError, "you can't create an appointment with yourself", fn ->
        Schedules.create_appointment(
          customer,
          %{date: ~U[2021-08-27 10:00:00.000000Z], provider_id: customer.id}
        )
      end
    end
  end

  describe "list_provider_month_availability/3" do
    setup do
      %User{id: provider_id} = user_fixture(%{user_role: "provider"})

      %{provider_id: provider_id}
    end

    test "with valid params returns the provider month availability", %{provider_id: provider_id} do
      availability_response = Enum.map(1..31, &%{day: &1, available: true})

      assert Schedules.list_provider_month_availability(
               provider_id,
               2021,
               1
             ) == availability_response

      appointment_fixture(provider_id, %{date: ~U[2021-02-01 08:00:00.000000Z]})

      assert Schedules.list_provider_month_availability(
               provider_id,
               2021,
               1
             ) == availability_response

      create_appointments_for_a_day(provider_id, 2021, 1, 2)
      create_appointments_for_a_day(provider_id, 2021, 1, 7)

      month_availability = Schedules.list_provider_month_availability(provider_id, 2021, 1)

      assert Enum.find(month_availability, &(&1.day == 2)) == %{day: 2, available: false}
      assert Enum.find(month_availability, &(&1.day == 7)) == %{day: 7, available: false}
    end
  end

  describe "list_provider_day_availability/2" do
    setup do
      %User{id: provider_id} = user_fixture(%{user_role: "provider"})

      %{provider_id: provider_id}
    end

    test "with valid params returns the provider day availability", %{provider_id: provider_id} do
      date = ~D[2021-01-01]

      available_day =
        for hour <- Schedules.hour_interval() do
          %{hour: hour, available: true}
        end

      assert Schedules.list_provider_day_availability(provider_id, date) == available_day

      # change the current time to 10 o'clock, making 8, 9 and 10 hours unavailable
      stub(GoBarber.DateProvider.Mock, :utc_now, fn -> ~U[2021-01-01 10:00:00.000000Z] end)

      refute Schedules.list_provider_day_availability(provider_id, date) == available_day

      hours_that_became_unavailable = [8, 9, 10]
      hours_to_schedule = [11, 13, 17]

      Enum.each(hours_to_schedule, fn hour ->
        appointment_fixture(provider_id, %{date: DateTime.new!(date, Time.new!(hour, 0, 0))})
      end)

      unavailable_hours =
        provider_id
        |> Schedules.list_provider_day_availability(date)
        |> Enum.filter(&(&1.hour in (hours_that_became_unavailable ++ hours_to_schedule)))

      expected_response =
        for hour <- hours_that_became_unavailable ++ hours_to_schedule,
            do: %{hour: hour, available: false}

      assert unavailable_hours == expected_response
    end
  end
end
