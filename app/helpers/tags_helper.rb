# frozen_string_literal: true

# app-specific tags
module TagsHelper
  HEADER_CLASSES          = "flex justify-between py-2 md:py-4"
  HEADING_1_CLASSES       = "font-bold text-2xl"
  BUTTON_CLASSES          = "text-sm font-bold uppercase tracking-wider px-4 py-2 border rounded"
  BUTTON_CLASSES_PRIMARY  = "bg-brand-500 hover:bg-brand-600 text-white border-brand-500 hover:border-brand-600"

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

  # rubocop:disable Metrics/AbcSize
  def switch(object_name, method, options = {}, checked_value, unchecked_value)
    wrapper_classes = ["switch-wrapper"]
    wrapper_classes << "switch-on" if options[:checked]
    wrapper_classes << "disabled" if options[:disabled]
    wrapper_classes << options[:css_classes] if options[:css_classes].present?

    switch_classes = "inline-block switch-container rounded-full bg-stone-500 w-14 h-8 relative p-1 \
      group-[.is-disabled]:bg-stone-300 dark:group-[.is-disabled]:bg-stone-700"
    button_classes = "switch-button absolute block w-6 h-6 rounded-full bg-white dark:bg-stone-600"

    content_tag(:div, class: wrapper_classes.join(" ")) do
      check_box(object_name, method, { checked: options[:checked], role: "switch" }, checked_value, unchecked_value) +
        label(object_name, method, class: "flex items-center") do
          content_tag(:div, class: switch_classes) do
            content_tag(:div, nil, class: button_classes)
          end + content_tag(:span, options[:label], class: "ml-2")
        end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
