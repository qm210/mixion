defmodule Mixion.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :timestamp, :naive_datetime
      add :bartender, :string
      add :recipe, references(:recipes, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:orders, [:recipe])
  end
end
