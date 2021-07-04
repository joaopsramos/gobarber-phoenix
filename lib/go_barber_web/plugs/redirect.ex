defmodule GoBarberWeb.Redirect do
  def init(opts) do
    if Keyword.has_key?(opts, :to) do
      opts
    else
      raise("Missing required option ':to' in redirect")
    end
  end

  def call(conn, opts) do
    conn
    |> Plug.Conn.put_status(301)
    |> Phoenix.Controller.redirect(opts)
  end
end
