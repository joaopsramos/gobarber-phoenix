defmodule GoBarberWeb.ComponentLive.Input do
  use GoBarberWeb, :live_component

  def render(assigns) do
    ~L"""
    <label for="<%= @label_for %>" class="flex items-center p-4 bg-inputs rounded-lg border-2 transition-all duration-200
                <%= if @focused, do: "border-orange", else: "border-inputs" %>">
      <%= @icon &&
            fi_icon(
              @icon,
              class:
                "mr-3 w-6 h-6 #{if @focused || @value != "", do: "text-orange", else: "text-gray-hard"}"
            ) %>
      <%= text_input(
            @f,
            @field,
            List.flatten([
              {:phx_focus, "focus"},
              {:phx_blur, "blur"},
              {:phx_target, @myself},
              {:value, @value},
              {:class, "bg-inputs placeholder-gray-hard text-white focus:outline-none"},
              @input_opts
            ])
          ) %>
      <div class="relative">
        <div class="group">
          <%= if @has_error do %>
            <%= fi_icon "alert-circle", class: "w-5 h-5 ml-4 text-red" %>
            <div class="error-tooltip">
              <span class="triangle absolute top-full left-2/4 transform -translate-x-2/4"></span>
              <%= error_tag @f, @field %>
            </div>
          <% end %>
        </div>
      </div>
    </label>
    """
  end

  def mount(socket) do
    {:ok, assign(socket, focused: false, value: "", icon: nil)}
  end

  def update(%{f: form, field: field} = assigns, socket) do
    label_for = "#{form.id}_#{field}"

    has_error =
      form.errors
      |> Keyword.get_values(field)
      |> Enum.empty?()
      |> Kernel.!()

    input_opts = assigns[:input] || []
    value = input_value(form, field)

    updated_assigns =
      if value || assigns[:input][:value] do
        Map.merge(assigns, %{
          value: value,
          label_for: label_for,
          input_opts: input_opts,
          has_error: has_error
        })
      else
        Map.merge(assigns, %{
          label_for: label_for,
          input_opts: input_opts,
          has_error: has_error
        })
      end

    {:ok, assign(socket, updated_assigns)}
  end

  def handle_event("focus", %{"value" => value}, socket) do
    {:noreply, assign(socket, focused: true, value: value)}
  end

  def handle_event("blur", %{"value" => value}, socket) do
    {:noreply, assign(socket, focused: false, value: value)}
  end
end
