defmodule GoBarberWeb.Helpers.IconHelper do
  use Phoenix.HTML

  @bi_types regular: "bx", solid: "bxs", logo: "bxl"

  def fi_icon(icon, opts \\ []) do
    classes = opts[:class] || ""
    attrs = Keyword.put(opts, :class, classes <> " fi-icon")

    content_tag(
      :svg,
      tag(:use, "xlink:href": "/images/feather-sprite.svg\##{icon}"),
      attrs
    )
  end

  def bi_icon(icon, opts \\ []) do
    classes = opts[:class] || ""

    icon_type = opts[:type] || :regular
    prefix = @bi_types[icon_type]

    attrs = Keyword.put(opts, :class, classes <> " bx #{prefix}-#{icon}")

    content_tag(:i, "", attrs)
  end
end
