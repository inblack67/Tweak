defmodule Tweak.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :username, :string
      add :body, :string
      add :likes, :integer
      add :reposts, :integer

      timestamps()
    end
  end
end
