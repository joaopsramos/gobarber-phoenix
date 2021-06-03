defmodule GoBarber.DateProvider do
  @callback utc_now() :: DateTime.t()
  @callback utc_today() :: Date.t()

  def impl(), do: Application.get_env(:go_barber, :date_provider_impl)

  def utc_now() do
    impl().utc_now()
  end

  def utc_today() do
    impl().utc_today()
  end
end
