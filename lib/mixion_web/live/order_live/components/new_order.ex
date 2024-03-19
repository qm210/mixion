defmodule MixionWeb.OrderLive.NewOrder do
  use MixionWeb, :live_component

  alias Mixion.Orders
  import MixionWeb.OrderLive.UndoButton

  defmodule JustAdded do
    @enforce_keys [:recipe_id, :bartender]
    defstruct [:recipe_id, :bartender]
  end

  @impl true
  def mount(socket) do
    recipes = Mixion.Recipes.list_recipes()
    bartenders = Mixion.Bartenders.all()
    IO.inspect(bartenders, label: "Bartenders")

    # counts = Enum.into(
    #   recipes,
    #   %{},
    #   fn recipe ->
    #     {recipe.id, %{left: 0, right: 0}}
    #   end
    # )

    added = []

    # added = added ++ [%JustAdded{recipe_id: 1, bartender: :left}]

    counts = Enum.into(
      recipes,
      %{},
      fn recipe ->
        # bartender_map = Enum.reduce(
        #   bartenders,
        #   %{},
        #   fn key, acc ->
        #     Map.put(acc, key, 0)
        #   end
        # )
        bartender_map = Enum.into(
          bartenders,
          %{},
          fn bartender -> {bartender, 0} end
        )
        {recipe.id, bartender_map}
      end
    )

    {:ok,
      socket
      |> assign(:recipes, recipes)
      |> assign(:counts, counts)
      |> assign(:bartenders, bartenders)
      |> assign(:added, added)
    }
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
      </.header>

      <div class="new-order-table">
        <table>
        <tbody>

            <%= for recipe <- @recipes do %>
              <tr>
                <td style="width: 100%">
                  <%= recipe.name %>
                </td>
                <%= for bartender <- @bartenders do %>
                  <td>
                    <.live_component
                      module = {MixionWeb.OrderLive.OrderCountButton}
                      id = {"count-#{recipe.id}-#{bartender}"}
                      parent_id = {@id}
                      counts = {@counts[recipe.id]}
                      recipe_id = {recipe.id}
                      bartender = {bartender}
                    />
                  </td>
                <% end %>
              </tr>
            <% end %>

        </tbody>
        </table>
      </div>

      <.button class="w-full mt-4" phx-click="submit" phx-target={@myself}>
        Submit
      </.button>

      <.undo_button
        :if={Enum.any?(@added)}
        target={@myself}
      />

      <div style="display: none">
        Some Footer text only to show that the self-closing .undo_button does not destroy me.
      </div>
    </div>
    """
  end

  @impl true
  def update(%{order: order} = assigns, socket) do
    changeset = Orders.change_order(order)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def update(%{event: :increment_event, params: params} = assigns, socket) do
    IO.inspect assigns, label: "NewOrder Assigns"

    %{"bartender" => bartender} = params
    recipe_id = String.to_integer(params["recipe_id"])

    # current_count = Map.get(socket.assigns.counts, bartender, 0)
    # Map.put(socket.assigns.counts, bartender, current_count + 1)

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

    socket = socket |>
      update(
        :counts,
        fn counts ->
          Map.update!(counts, recipe_id, fn count ->
            key = String.to_atom(bartender)
            Map.update!(count, key, &(&1 + 1))
          end)
        end
      )
      |> update(
        :added,
        fn added ->
          added ++ [%JustAdded{bartender: bartender, recipe_id: recipe_id}]
        end
      )

    IO.inspect socket.assigns.added, label: "Added"

    {:ok, socket}
  end

  @impl true
  def handle_event("validate", %{"order" => order_params}, socket) do
    changeset =
      socket.assigns.order
      |> Orders.change_order(order_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  @impl true
  def handle_event("save", %{"order" => order_params}, socket) do
    save_order(socket, socket.assigns.action, order_params)
  end

  @impl true
  def handle_event("submit", params, socket) do
    IO.inspect(params, label: "INSIDE SUBMIT")
    # Your logic here for handling the right_click event
    # For example, you might want to update some state or perform an action
    {:noreply, socket}
  end

  @impl true
  def handle_event("increment", params, socket) do
    IO.inspect(params, label: "outer increment")
    {:noreply, socket}
  end

  @impl true
  def handle_event(:increment, params, socket) do
    IO.inspect(params, label: "outer :increment")
    {:noreply, socket}
  end

  def handle_info({:increment, params}, socket) do
    IO.inspect(params, label: "Outer increment handle_info")
    {:noreply, socket}
  end

  def handle_info({:increment_event, params}, socket) do
    IO.inspect(params, label: "Outer increment_event handle_info")
    {:noreply, socket}
  end

  defp save_order(socket, :edit, order_params) do
    case Orders.update_order(socket.assigns.order, order_params) do
      {:ok, order} ->
        notify_parent({:saved, order})

        {:noreply,
         socket
         |> put_flash(:info, "Order updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_order(socket, :new, order_params) do
    case Orders.create_order(order_params) do
      {:ok, order} ->
        notify_parent({:saved, order})

        {:noreply,
         socket
         |> put_flash(:info, "Order created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  # could also define the component here, but I used import ... and it worked.
  # def undo_button(assigns) do
  #   ~H"""
  #   <.button class="mt-8 bg-red-500 w-full">
  #     HAHAHA
  #   </.button>
  #   """
  # end

end
