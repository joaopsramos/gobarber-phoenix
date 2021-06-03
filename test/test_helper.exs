ExUnit.start()

Hammox.defmock(GoBarber.DateProvider.Mock, for: GoBarber.DateProvider)

Ecto.Adapters.SQL.Sandbox.mode(GoBarber.Repo, :manual)
