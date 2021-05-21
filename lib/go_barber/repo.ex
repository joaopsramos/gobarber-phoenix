defmodule GoBarber.Repo do
  use Ecto.Repo,
    otp_app: :go_barber,
    adapter: Ecto.Adapters.Postgres
end
