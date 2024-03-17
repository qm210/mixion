defmodule Mixion.Orders.Order do
  use Ecto.Schema
  import Ecto.Changeset

  schema "orders" do
    field :timestamp, :naive_datetime
    field :bartender, :string
    field :recipe, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(order, attrs) do
    order
    |> cast(attrs, [:timestamp, :bartender])
    |> validate_required([:timestamp, :bartender])
  end
end
