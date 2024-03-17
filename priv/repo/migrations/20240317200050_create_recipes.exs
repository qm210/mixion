defmodule Mixion.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string
      add :color, :string
      add :steps, :string

      timestamps(type: :utc_datetime)
    end
  end
end
