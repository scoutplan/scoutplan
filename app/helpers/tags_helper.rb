# frozen_string_literal: true

# app-specific tags
module TagsHelper
  HEADING_1_CLASSES = "font-bold text-2xl mb-4"

  # yields a header tag correctly styled via Tailwind
  # usage:
  # <%= styled_header_tag "Page Title" %>
  #
  # or
  #
  # <%= styled_header_tag "Page Title" do %>
  #  <%= link_to "Button-styled link", some_path %>
  # <% end %>
  #
  # in the latter usage, the stuff in the block will be justified hard right:
  #
  # +----------------------------------------+
  # |                                        |
  # | Title                            Block |
  # |                                        |
  # +----------------------------------------+
  #
  #
  #
  def styled_header_tag(title, &block)
    content_tag :header, class: "flex justify-between" do
      concat(content_tag(:h1, title, class: HEADING_1_CLASSES))
      if block_given?
        concat(content_tag(:div) do
          yield block
        end)
      end
    end
  end
end
