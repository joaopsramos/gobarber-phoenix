defmodule GoBarberWeb.ComponentLive.Toasts do
  use GoBarberWeb, :live_component

  @default_duration 5
  @animation_time 500

  def render(assigns) do
    ~L"""
      <div class="absolute right-0 top-0 p-5 overflow-hidden">
        <ul>
          <%= for toast <- @toasts do %>
            <li class="mb-4 transform transition-all duration-<%= @animation_time %> <%= toast.class %>">
              <div class="flex relative py-3 pl-2 rounded-lg shadow-lg <%= toast.colors %>">
                <%= fi_icon toast.icon, class: "w-6 h-6 mr-2" %>

                <div class="w-72 mr-8">
                  <h3 class="font-bold"><%= toast.title %></h3>

                  <%= if toast[:description] do %>
                  <p class="mt-1 text-sm"><%= toast.description %></p>
                  <% end %>
                </div>

                <%= fi_icon "x-circle",
                      phx_click: "delete_toast",
                      phx_value_id: toast.id,
                      phx_target: @myself,
                      class: "absolute top-1 right-1 w-5 h-5 cursor-pointer"
                %>
              </div>
            </li>
          <% end %>
        </ul>
      </div>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, toasts: [], animation_time: @animation_time)}
  end

  def update(%{action: :add, toast: toast}, socket) do
    toasts = [toast] ++ socket.assigns.toasts
    {:ok, assign(socket, toasts: toasts)}
  end

  def update(%{action: :show, toast_id: toast_id}, socket) do
    toasts =
      Enum.map(socket.assigns.toasts, fn toast ->
        if toast.id == toast_id do
          Map.put(toast, :class, "translate-x-0 opacity-1")
        else
          toast
        end
      end)

    {:ok, assign(socket, toasts: toasts)}
  end

  def update(%{action: :hide, toast_id: toast_id}, socket) do
    toasts =
      Enum.map(socket.assigns.toasts, fn toast ->
        if toast.id == toast_id do
          Map.put(toast, :class, "translate-x-96 opacity-0")
        else
          toast
        end
      end)

    {:ok, assign(socket, toasts: toasts)}
  end

  def update(%{action: :delete, toast_id: toast_id}, socket) do
    toasts = Enum.reject(socket.assigns.toasts, &(&1.id == toast_id))
    {:ok, assign(socket, toasts: toasts)}
  end

  def update(_assigns, socket) do
    {:ok, socket}
  end

  def handle_event("delete_toast", %{"id" => toast_id}, socket) do
    toast_id
    |> String.to_integer()
    |> hide_and_delete(0)

    {:noreply, socket}
  end

  defp put_icon_and_colors(toasts) when is_list(toasts),
    do: Enum.map(toasts, &put_icon_and_colors/1)

  defp put_icon_and_colors(toast) do
    props =
      case toast.type do
        :success ->
          %{icon: "check-circle", colors: "bg-toast-back-success text-toast-color-success"}

        :info ->
          %{icon: "info", colors: "bg-toast-back-info text-toast-color-info"}

        :danger ->
          %{icon: "alert-triangle", colors: "bg-toast-back-error text-toast-color-error"}
      end

    Map.merge(toast, props)
  end

  def add_toast(socket, props) do
    duration = :timer.seconds(props[:duration] || @default_duration)

    toast = %{
      id: :rand.uniform(1000),
      type: props[:type] || :info,
      title: props[:title],
      description: props[:description],
      class: "translate-x-96 opacity-0"
    }

    send_updates(toast, duration)

    socket
  end

  defp send_updates(toast, duration) do
    add_and_show(toast)
    hide_and_delete(toast.id, duration)
  end

  defp add_and_show(toast) do
    send_update(
      __MODULE__,
      id: "toast",
      action: :add,
      toast: put_icon_and_colors(toast)
    )

    send_update_after(
      __MODULE__,
      [id: "toast", action: :show, toast_id: toast.id],
      @animation_time
    )
  end

  defp hide_and_delete(toast_id, duration) do
    send_update_after(
      __MODULE__,
      [id: "toast", action: :hide, toast_id: toast_id],
      duration
    )

    send_update_after(
      __MODULE__,
      [id: "toast", action: :delete, toast_id: toast_id],
      # + 10s to not change position
      duration + :timer.seconds(10)
    )
  end
end
