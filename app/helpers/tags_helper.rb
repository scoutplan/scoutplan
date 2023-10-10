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

  # drop-in replacement for Rails's check_box helper
  # rubocop:disable Metrics/AbcSize
  def switch(object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
    wrapper_classes = ["switch-wrapper"]
    wrapper_classes << "switch-on" if options[:checked]
    wrapper_classes << "group is-disabled" if options[:disabled]
    wrapper_classes << options[:css_classes] if options[:css_classes].present?

    switch_classes = "inline-block switch-container rounded-full bg-stone-500 w-[3.5em] h-[2em] relative p-[0.25em] \
      group-[.is-disabled]:bg-stone-300 dark:group-[.is-disabled]:bg-stone-700 shrink-0"
    button_classes = "switch-button absolute block w-[1.5em] h-[1.5em] rounded-full bg-white group-[.is-disabled]:bg-stone-400 dark:group-[.is-disabled]:bg-stone-600]"

    content_tag(:div, class: wrapper_classes.join(" ")) do
      check_box(object_name, method, { checked: options[:checked], disabled: options[:disabled], data: options[:data], role: "switch" }, checked_value, unchecked_value) +
        label(object_name, method, class: "flex items-center group-[.is-disabled]:text-stone-400 dark:group-[.is-disabled]:text-stone-700") do
          content_tag(:div, class: switch_classes) do
            content_tag(:div, nil, class: button_classes)
          end + content_tag(:span, options[:label], class: "ml-2")
        end
    end
  end
  # rubocop:enable Metrics/AbcSize
end
