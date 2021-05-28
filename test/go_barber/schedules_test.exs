defmodule GoBarber.SchedulesTest do
  use GoBarber.DataCase, async: true
  alias GoBarber.Schedules
  alias GoBarber.Schedules.Appointment

  describe "create_appointment/1" do
    @valid_attrs %{date: ~U[2022-01-01 08:00:00.000000Z]}
    @invalid_attrs %{date: nil}

    setup do
      {
        :ok,
        provider: user_fixture(%{user_role: "provider"}),
        customer: user_fixture(%{user_role: "customer"})
      }
    end

    test "with valid data create an appointment", %{provider: provider, customer: customer} do
      assert {:ok, %Appointment{} = appointment} =
               Schedules.create_appointment(
                 %{customer: customer, provider: provider},
                 @valid_attrs
               )

      assert DateTime.compare(@valid_attrs.date, appointment.date) == :eq
    end

    test "with invalid data returns error changeset", %{provider: provider, customer: customer} do
      assert {:error, %Ecto.Changeset{}} =
               Schedules.create_appointment(
                 %{customer: customer, provider: provider},
                 @invalid_attrs
               )
    end

    test "if hour is not between 08:00 and 17:00 returns error changeset", %{
      provider: provider,
      customer: customer
    } do
      assert {:error, %Ecto.Changeset{errors: [date: {"hour must be between 8 and 17", _}]}} =
               Schedules.create_appointment(
                 %{customer: customer, provider: provider},
                 %{date: ~U[2021-06-01 07:00:00.000000Z]}
               )

      assert {:error, %Ecto.Changeset{errors: [date: {"hour must be between 8 and 17", _}]}} =
               Schedules.create_appointment(
                 %{customer: customer, provider: provider},
                 %{date: ~U[2021-06-01 18:00:00.000000Z]}
               )

      assert {:ok, %Appointment{}} =
               Schedules.create_appointment(
                 %{customer: customer, provider: provider},
                 @valid_attrs
               )
    end

    test "if another appointment is already on the same date raises an error", %{
      provider: provider,
      customer: customer
    } do
      assert {:ok, %Appointment{}} =
               Schedules.create_appointment(
                 %{customer: customer, provider: provider},
                 @valid_attrs
               )

      assert_raise RuntimeError, "there is already another appointment for that date", fn ->
        Schedules.create_appointment(
          %{customer: customer, provider: provider},
          @valid_attrs
        )
      end
    end

    test "if date is a past date raises an error", %{
      provider: provider,
      customer: customer
    } do
      assert_raise RuntimeError, "date can't be a past date", fn ->
        Schedules.create_appointment(
          %{customer: customer, provider: provider},
          %{date: ~U[2021-05-27 10:00:00.000000Z]}
        )
      end
    end
  end
end
