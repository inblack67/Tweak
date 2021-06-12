defmodule TweakWeb.PostLive.FormComponent do
  use TweakWeb, :live_component

  alias Tweak.Timeline
  alias Tweak.Timeline.Post

  @impl true
  def mount(socket) do
    # default max entry is 1
    {:ok, allow_upload(socket, :photo, accept: ~w(.png .jpg .jpeg), max_entries: 2)}
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Timeline.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  defp save_post(socket, :edit, post_params) do
    post = put_photo_urls(socket, socket.assigns.post)

    # run consume_photos after creating post
    case Timeline.update_post(post, post_params, &consume_photos(socket, &1)) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    post = put_photo_urls(socket, %Post{})

    case Timeline.create_post(post, post_params, &consume_photos(socket, &1)) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  def consume_photos(socket, %Post{} = post) do
    consume_uploaded_entries(socket, :photo, fn meta, entry ->
      dest = Path.join("priv/static/uploads", "#{entry.uuid}.#{ext(entry)}")
      File.cp!(meta.path, dest)
    end)

    {:ok, post}
  end

  defp put_photo_urls(socket, %Post{} = post) do
    {completed, []} = uploaded_entries(socket, :photo)

    urls =
      for entry <- completed do
        Routes.static_path(socket, "/uploads/#{entry.uuid}.#{ext(entry)}")
      end

    %Post{post | photo_urls: urls}
  end
end
