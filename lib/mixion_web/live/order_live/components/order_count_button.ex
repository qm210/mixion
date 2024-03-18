defmodule MixionWeb.OrderLive.OrderCountButton do
  use MixionWeb, :live_component

  @impl true
  def handle_event("increment", params, socket) do
    %{"recipe_id" => _recipe_id, "bartender" => bartender} = params

    # current_count = Map.get(socket.assigns.counts, bartender, 0)
    # Map.put(socket.assigns.counts, bartender, current_count + 1)

    socket = socket |>
      update(
        :counts,
        fn counts ->
          b = String.to_atom(bartender)
          Map.update!(counts, b, &(&1 + 1))
        end
      )

    # &(&1 + 1) is a capturing expression, i.e. anonymous function
    # &1 is the first argument passed to this function
    # &() is the definition itself
    # i.e. it is the same as fn x -> x + 1 end

    # more fucked up way to write this...?
    # socket = socket |> update(:counts, fn counts ->
    #   counts
    #   |> Map.get(bartender, 0)
    #   |> Kernel.+(1)
    #   |> (&Map.put(counts, bartender, &1)).()
    # end)

    # send_update(
    #   MixionWeb.OrderLive.NewOrderComponent,
    #   id: socket.id,
    #   event: "increment",
    #   params: params
    # )

    # has to be handled by handle_info inside the LiveView then

    # if Map.has_key?(socket.assigns, :parent_id) do
    #   # doesn't work
    #   send(socket.id, {:increment_event, params})
    # else
    #   send(self(), {:increment_event, params})
    # end

    IO.inspect self(), label: "Self"
    IO.inspect socket.assigns, label: "Assigns"

    send(self(), {:increment_event, params})

    if Map.has_key?(socket.assigns, :parent_pid) do
      send_update(
        MixionWeb.OrderLive.NewOrderComponent,
        id: :new_order_component,
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
