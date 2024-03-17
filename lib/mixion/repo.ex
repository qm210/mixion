defmodule Mixion.Repo do
  use Ecto.Repo,
    otp_app: :mixion,
    adapter: Ecto.Adapters.SQLite3
end
