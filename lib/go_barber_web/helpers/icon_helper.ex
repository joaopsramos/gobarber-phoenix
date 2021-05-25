defmodule GoBarberWeb.Helpers.IconHelper do
  use Phoenix.HTML

  def fi_icon(icon, opts \\ []) do
    classes = opts[:class] || ""
    updated_opts = Keyword.put(opts, :class, classes <> " fi-icon")

    content_tag :svg, updated_opts do
      tag(:use, "xlink:href": "/images/feather-sprite.svg\##{icon}")
    end
  end
end
