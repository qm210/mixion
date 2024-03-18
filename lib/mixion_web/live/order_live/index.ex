defmodule MixionWeb.OrderLive.Index do
  use MixionWeb, :live_view

  alias Mixion.Orders
  alias Mixion.Orders.Order

  @impl true
  def mount(_params, _session, socket) do
    orders = Orders.list_orders()
    {:ok, stream(socket, :orders, orders)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Order")
    |> assign(:order, Orders.get_order!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Order")
    |> assign(:order, %Order{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Orders")
    |> assign(:order, nil)
  end

  @impl true
  def handle_info({MixionWeb.OrderLive.FormComponent, {:saved, order}}, socket) do
    {:noreply, stream_insert(socket, :orders, order)}
  end

  # Wasserträger, lel
  def handle_info({:increment_event, params}, socket) do
    IO.inspect params
    # send(:new_order_component, {:increment_event, params})  fails
    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    order = Orders.get_order!(id)
    {:ok, _} = Orders.delete_order(order)

    {:noreply, stream_delete(socket, :orders, order)}
  end

  @impl true
  def handle_event("submit", params, socket) do
    IO.inspect(params, label: "OUTSIDE SUBMIT")
    {:noreply, socket}
  end
end
