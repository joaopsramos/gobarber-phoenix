defmodule GoBarberWeb.Helpers.IconHelper do
  use Phoenix.HTML

  def fi_icon(icon, opts \\ []) do
    classes = Keyword.get(opts, :class, "") <> " w-6 h-6 fi-icon"

    content_tag :svg, class: classes do
      tag(:use,
        "xlink:href": "/images/feather-sprite.svg\##{icon}"
      )
    end
  end
end
