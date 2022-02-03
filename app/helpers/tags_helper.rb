# app-specific tags
module TagsHelper
  HEADER_CLASSES = "flex justify-between py-8"
  HEADING_1_CLASSES = "font-bold text-2xl"
  BUTTON_CLASSES = "text-sm font-bold uppercase tracking-wider px-4 py-2 border rounded"
  BUTTON_CLASSES_PRIMARY = "bg-brand-500 hover:bg-brand-600 text-white border-brand-500 hover:border-brand-600"

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
    content_tag :header, class: HEADER_CLASSES do
      concat(content_tag(:h1, title, class: HEADING_1_CLASSES))
      if block_given?
        concat(content_tag(:div) do
          yield block
        end)
      end
    end
  end

  def styled_link_to(name = nil, options = nil, html_options = nil, &block)
    classes = BUTTON_CLASSES.dup
    classes = classes << " " << BUTTON_CLASSES_PRIMARY.dup

    if options.is_a? Hash
      options[:class] = (options[:class] || "") << " " << classes
    else
      html_options[:class] = (html_options[:class] || "") << " " << classes
    end
    link_to(name, options, html_options, &block)
  end
end
