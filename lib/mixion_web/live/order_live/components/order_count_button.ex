defmodule MixionWeb.OrderLive.OrderCountButton do
  use MixionWeb, :live_component

  @impl true
  def handle_event("increment", params, socket) do

    if Map.has_key?(socket.assigns, :parent_id) do
      # for the update, any combination of module + id is a key,
      # i.e. these are treated as identical
      send_update(
        MixionWeb.OrderLive.NewOrder,
        id: socket.assigns.parent_id,
        event: :increment_event,
        params: params
      )
    end

    {:noreply, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <span :if={@counts[@bartender] > 0}>
        <%= @counts[@bartender] %>
      </span>
      <.button
        phx-click = "increment"
        phx-value-recipe_id = {@recipe_id}
        phx-value-bartender = {@bartender}
        phx-target = {@myself}
        >
        <%= String.capitalize(Atom.to_string(@bartender)) %>
      </.button>
    </div>
    """
  end

end
