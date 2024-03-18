defmodule Mixion.Bartenders do
  def left, do: :left
  def right, do: :right

  def all, do: [left(), right()]
end
