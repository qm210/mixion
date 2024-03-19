defmodule MixionWeb.OrderLive.UndoButton do
  use Phoenix.Component

  def undo_button(assigns) do
    # make @title optional
    assigns = assigns |> assign_new(:title, fn -> nil end)
    ~H"""
    <button
      type="button"
      class="mt-4 bg-red-500 hover:bg-red-400 w-full p-2 rounded-lg text-white font-bold"
      phx-click="undo"
      phx-target={@target}
      >
      <%= @title || "Undo" %>
    </button>
    """
  end

end
