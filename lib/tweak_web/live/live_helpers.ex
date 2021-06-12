defmodule TweakWeb.LiveHelpers do
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `TweakWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, TweakWeb.PostLive.FormComponent,
        id: @post.id || :new,
        action: @live_action,
        post: @post,
        return_to: Routes.post_index_path(@socket, :index) %>
  """
  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(TweakWeb.ModalComponent, modal_opts)
    # live_component(socket, TweakWeb.ModalComponent, modal_opts)
  end
end
