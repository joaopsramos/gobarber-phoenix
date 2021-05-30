ExUnit.start()

Hammox.defmock(GoBarber.DateTime.Mock, for: GoBarber.DateTime)

Ecto.Adapters.SQL.Sandbox.mode(GoBarber.Repo, :manual)
