defmodule GoBarber.DateTime do
  @callback utc_now() :: DateTime.t()

  def impl(), do: Application.get_env(:go_barber, :datetime_impl)

  def utc_now() do
    impl().utc_now()
  end
end
