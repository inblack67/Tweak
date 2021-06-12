defmodule Tweak.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  schema "posts" do
    field(:body, :string)
    field(:likes, :integer, default: 0)
    field(:reposts, :integer, default: 0)
    field(:username, :string, default: "inblack67")

    timestamps()
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:username, :body, :likes, :reposts])
    |> validate_required([:username, :body, :likes, :reposts])
  end
end
