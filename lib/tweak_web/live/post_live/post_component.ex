defmodule TweakWeb.PostLive.PostComponent do
  use TweakWeb, :live_component

  def render(assigns) do
    ~L"""
    <tr id="post-<%= @post.id %>">
    <td><%= @post.username %></td>
    <td><%= @post.body %></td>
    <td>
     <a href="#" phx-click="like" phx-target="<%= @myself %>">
      <%= @post.likes %>
     </a>
    </td>
    <td>
    <a href="#" phx-click="repost" phx-target="<%= @myself %>">
    <%= @post.reposts %>
    </a>
    </td>
    <td>
      <span><%= live_redirect "Show", to: Routes.post_show_path(@socket, :show, @post) %></span>
      <span><%= live_patch "Edit", to: Routes.post_index_path(@socket, :edit, @post) %></span>
      <span><%= link "Delete", to: "#", phx_click: "delete", phx_value_id: @post.id, data: [confirm: "Are you sure?"] %></span>
    </td>
    </tr>
    """
  end

  def handle_event("like", _, socket) do
    Tweak.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    Tweak.Timeline.inc_reposts(socket.assigns.post)
    {:noreply, socket}
  end
end
