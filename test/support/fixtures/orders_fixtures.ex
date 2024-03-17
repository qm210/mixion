defmodule Mixion.OrdersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mixion.Orders` context.
  """

  @doc """
  Generate a order.
  """
  def order_fixture(attrs \\ %{}) do
    {:ok, order} =
      attrs
      |> Enum.into(%{
        bartender: "some bartender",
        timestamp: ~N[2024-03-16 20:01:00]
      })
      |> Mixion.Orders.create_order()

    order
  end
end
