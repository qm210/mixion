defmodule Mixion.RecipesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Mixion.Recipes` context.
  """

  @doc """
  Generate a recipe.
  """
  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{
        color: "some color",
        name: "some name",
        steps: "some steps"
      })
      |> Mixion.Recipes.create_recipe()

    recipe
  end
end
