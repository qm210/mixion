defmodule MixionWeb.OrderLive.NewOrderComponent do
  use MixionWeb, :live_component

  alias Mixion.Orders

  def mount(socket) do
    recipes = Mixion.Recipes.list_recipes()
    counts = Enum.into(
      recipes,
      %{},
      fn recipe ->
        {recipe.id, %{left: 0, right: 0}}
      end
    )
    IO.inspect(counts, label: "Counts")

    {:ok,
      socket
      |> assign(:recipes, recipes)
      |> assign(:counts, counts)
    }
  end

  @impl true
  def handle_event("submit", _params, socket) do
    IO.inspect(_params, label: "INSIDE SUBMIT")
    # Your logic here for handling the right_click event
    # For example, you might want to update some state or perform an action
    {:noreply, socket}
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
                <td>
                  <span :if={@counts[recipe.id].left > 0}>
                    <%= @counts[recipe.id].left %>
                  </span>
                  <.button
                    phx-click="increment"
                    phx-value-recipe_id={recipe.id}
                    phx-value-bartender="left">
                    Left
                  </.button>
                </td>
                <td>
    <!-- TODO: Vorhergehende Zelle mal auslagern in eigene Funktionalkomponente, nur noch duplizieren -->
                  <span :if={@counts[recipe.id].right > 0}>
                    <%= @counts[recipe.id].right %>
                  </span>
                  <.button>Right</.button>
                </td>
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

  #
#  def handle_event("increment", %{"recipe_id" => recipe_id, "bartender" => bartender}, socket) do
#    IO.inspect(socket.assigns.counts, label: "Increased counts")
#    #counts = update_in(socket.assigns.counts[recipe_id], &(&1 + 1))
#    {:noreply, assign(socket, counts: socket.assigns.counts)}
#    # {:noreply, socket |> assign(:counts, counts)}
#  end
#
#  def handle_event("debug", _params, socket) do
#    # Your logic here for handling the debug event
#    {:noreply, socket}
#  end

  # from here, the default stuff

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

  def handle_event("save", %{"order" => order_params}, socket) do
    save_order(socket, socket.assigns.action, order_params)
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
