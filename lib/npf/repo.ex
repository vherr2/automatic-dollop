defmodule Npf.Repo do
  use Ecto.Repo,
    otp_app: :npf,
    adapter: Ecto.Adapters.Postgres
end
