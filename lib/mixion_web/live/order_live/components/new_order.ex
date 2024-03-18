defmodule MixionWeb.OrderLive.NewOrderComponent do
  use MixionWeb, :live_component

  alias Mixion.Orders

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
                      parent_pid = {self()}
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

  @impl true
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


end
