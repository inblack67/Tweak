defmodule Tweak.Repo do
  use Ecto.Repo,
    otp_app: :tweak,
    adapter: Ecto.Adapters.Postgres
end
