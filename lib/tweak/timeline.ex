defmodule Tweak.Timeline do
  @moduledoc """
  The Timeline context.
  """

  import Ecto.Query, warn: false
  alias Tweak.Repo

  alias Tweak.Timeline.Post

  @doc """
  Returns the list of posts.

  ## Examples

      iex> list_posts()
      [%Post{}, ...]

  """
  def list_posts do
    Repo.all(from(p in Post, order_by: [desc: p.inserted_at]))
  end

  @doc """
  Gets a single post.

  Raises `Ecto.NoResultsError` if the Post does not exist.

  ## Examples

      iex> get_post!(123)
      %Post{}

      iex> get_post!(456)
      ** (Ecto.NoResultsError)

  """
  def get_post!(id), do: Repo.get!(Post, id)

  @doc """
  Creates a post.

  ## Examples

      iex> create_post(%{field: value})
      {:ok, %Post{}}

      iex> create_post(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_post(%Post{} = post, attrs \\ %{}, after_save \\ &{:ok, &1}) do
    post
    |> Post.changeset(attrs)
    |> Repo.insert()
    |> after_save(after_save)
    |> broadcast(:post_created)
  end

  defp after_save({:ok, post}, func) do
    {:ok, _post} = func.(post)
  end

  defp after_save(error, _func), do: error

  @doc """
  Updates a post.

  ## Examples

      iex> update_post(post, %{field: new_value})
      {:ok, %Post{}}

      iex> update_post(post, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_post(%Post{} = post, attrs, after_save \\ &{:ok, &1}) do
    post
    |> Post.changeset(attrs)
    |> Repo.update()
    |> after_save(after_save)
    |> broadcast(:post_updated)
  end

  @doc """
  Deletes a post.

  ## Examples

      iex> delete_post(post)
      {:ok, %Post{}}

      iex> delete_post(post)
      {:error, %Ecto.Changeset{}}

  """
  def delete_post(%Post{} = post) do
    Repo.delete(post)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking post changes.

  ## Examples

      iex> change_post(post)
      %Ecto.Changeset{data: %Post{}}

  """
  def change_post(%Post{} = post, attrs \\ %{}) do
    Post.changeset(post, attrs)
  end

  def inc_likes(%Post{id: id}) do
    # [numberofrecoreds returned, [record]]
    {1, [post]} =
      from(p in Post, where: p.id == ^id, select: p)
      |> Repo.update_all(inc: [likes: 1])

    broadcast({:ok, post}, :post_updated)
  end

  def inc_reposts(%Post{id: id}) do
    # [numberofrecoreds returned, [record]]
    {1, [post]} =
      from(p in Post, where: p.id == ^id, select: p)
      |> Repo.update_all(inc: [reposts: 1])

    broadcast({:ok, post}, :post_updated)
  end

  def subscribe do
    Phoenix.PubSub.subscribe(Tweak.PubSub, "posts")
  end

  # if db operation fails
  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:ok, post}, event) do
    Phoenix.PubSub.broadcast(Tweak.PubSub, "posts", {event, post})
    {:ok, post}
  end
end
