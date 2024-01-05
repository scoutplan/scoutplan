module TagsHelper
  def switch(object_name, method, options = {}, checked_value = "1", unchecked_value = "0")
    content_tag(:span, class: "switch-wrapper") do
      check_box(
        object_name, method,
        { checked: options[:checked], disabled: options[:disabled],
          data: options[:data], role: "switch", class: "dp-switch" },
        checked_value, unchecked_value
      ) +
        label(object_name, method, class: "flex items-center") do
          content_tag(:div, class: "switch-container") do
            content_tag(:div, nil, class: "switch-button")
          end + content_tag(:span, options[:label], class: "ml-2 select-none")
        end
    end
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Layout/MultilineOperationIndentation
  # rubocop:disable Layout/LineLength
  def double_throw_switch(object_name, method, options = {})
    content_tag(:span, class: "block dt-switch switch-wrapper #{options[:disabled] ? 'disabled' : ''} #{options[:wrapper_classes]}", data: { controller: "double-throw-switch" }) do
      radio_button(object_name, method, options[:left_value], { class: "left-value dp-switch", checked: options[:checked_left], disabled: options[:disabled] }) +
      radio_button(object_name, method, "nil", { class: "center-value dp-switch", checked: options[:checked_center], disabled: options[:disabled] }) +
      radio_button(object_name, method, options[:right_value], { class: "right-value  dp-switch", checked: options[:checked_right], disabled: options[:disabled] }) +
      content_tag(:span, class: "switch-container #{options[:disabled] ? 'disabled' : ''}") do
        content_tag(:div, nil, class: "switch-button") +
        label(object_name, method, value: options[:left_value], class: "left-label", data: { action: "click->double-throw-switch#click", position: "left" }) { options[:left_label] } +
        label(object_name, method, "", value: "nil", class: "center-label", data: { action: "click->double-throw-switch#click", position: "center" }) { "dummy" } +
        label(object_name, method, value: options[:right_value], class: "right-label", data: { action: "click->double-throw-switch#click", position: "right" }) { options[:right_label] }
      end
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Layout/MultilineOperationIndentation
  # rubocop:enable Layout/LineLength

  def back_link_to(body, url, html_options = {})
    html_options[:class] ||= ""
    html_options[:class] += " block font-bold"
    link_to(url, html_options) do
      content_tag(:i, nil, class: "fa-solid fa-chevron-left mr-2") +
        body
    end
  end
end
