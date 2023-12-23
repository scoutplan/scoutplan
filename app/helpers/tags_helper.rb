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

  def back_link_to(body, url, html_options = {})
    html_options[:class] ||= ""
    html_options[:class] += " block font-bold"
    link_to(url, html_options) do
      content_tag(:i, nil, class: "fa-solid fa-chevron-left mr-2") +
        body
    end
  end
end
