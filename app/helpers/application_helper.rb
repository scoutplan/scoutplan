# frozen_string_literal: true

# application-wide helpers
module ApplicationHelper
  def colors_from_string(string)
    hue = Digest::MD5.hexdigest(string).to_i(16) % 360
    bgcolor = "hsl(#{hue}, 100%, 95%)"
    color = "hsl(#{hue}, 100%, 20%)"
    [bgcolor, color]
  end

  def content_tag_if(tag, conditional, content = nil, options = nil)
    return unless conditional.present?

    content_tag(tag, content || conditional, options)
  end

  def string_for_time_internal_from_day(val)
    return "today" if val.today?
    return "tomorrow" if val.tomorrow?
    return "yesterday" if val.yesterday?
    return "in #{distance_of_time_in_words_to_now(val)}" if val.future?
    return "#{distance_of_time_in_words_to_now(val)} ago" if val.past?

    nil
  end

  def fontawesome_file_icon(extension, style = "fa-solid")
    raw(content_tag(:i, nil, class: "#{style} fa-fw fa-#{fontawesome_file_icon_name(extension)}"))
  end

  # rubocop:disable Metrics/MethodLength
  def fontawesome_file_icon_name(extension)
    case extension
    when "pdf"
      "file-pdf"
    when "doc", "docx"
      "file-word"
    when "xls", "xlsx"
      "file-excel"
    when "ppt", "pptx"
      "file-powerpoint"
    when "zip", "rar", "7z"
      "file-archive"
    when "txt"
      "file-alt"
    else
      "file"
    end
  end
  # rubocop:enable Metrics/MethodLength

  def pill_tag(text, additional_classes = nil)
    additional_classes ||= "text-white bg-gray-600"
    classes = "text-xs font-semibold inline text-center rounded px-2 py-1 mx-2 min-w-[2rem]"
    classes = [classes, additional_classes].join(" ")
    content_tag :span, text, class: classes
  end

  def pill_tag_if(condition, text, additional_classes = nil)
    pill_tag(text, additional_classes) if condition
  end

  def pill_tag_if_positive(number, additional_classes = nil)
    pill_tag_if(number.positive?, number, additional_classes)
  end

  def remembered_unit_events_path(unit)
    session[:events_index_path] || unit_events_path(unit)
  end

  # given a member, return the appropriate FontAwesome element tag
  def member_glyph_tag(member)
    colors = {
      "youth" => "sky-500",
      "adult" => "pink-500"
    }
    color = colors[member.member_type]

    content_tag :i, nil, class: "fa-user fad mr-1 text-#{color}", title: I18n.t("members.types.#{member.member_type}")
  end

  def pronoun(member, current_member)
    return "you" if member == current_member

    "them"
  end

  def possessive_pronoun(member, current_member)
    return "your" if member == current_member

    "their"
  end

  def name_or_pronoun(member, current_member)
    return "you" if member == current_member

    member.first_name
  end

  def possessive_name_or_pronoun(member, current_member)
    return "your" if member == current_member

    "#{member.first_name}'s"
  end

  # rubocop:disable Metrics/AbcSize
  # Amount should be a decimal between 0 and 1. Lower means darker
  def darken_color(hex_color, amount = 0.4)
    hex_color = hex_color.gsub("#", "")
    rgb = hex_color.scan(/../).map(&:hex)
    rgb[0] = (rgb[0].to_i * amount).round
    rgb[1] = (rgb[1].to_i * amount).round
    rgb[2] = (rgb[2].to_i * amount).round
    "#%02x%02x%02x" % rgb
  end

  # Amount should be a decimal between 0 and 1. Higher means lighter
  def lighten_color(hex_color, amount = 0.7)
    hex_color = HtmlColor.to_hex(hex_color) unless hex_color.starts_with?("#")
    return "" unless hex_color.respond_to?(:gsub)

    hex_color = hex_color.gsub("#", "")
    rgb = hex_color.scan(/../).map(&:hex)
    rgb[0] = [(rgb[0].to_i + (255 * amount)).round, 255].min
    rgb[1] = [(rgb[1].to_i + (255 * amount)).round, 255].min
    rgb[2] = [(rgb[2].to_i + (255 * amount)).round, 255].min
    "#%02x%02x%02x" % rgb
  end
  # rubocop:enable Metrics/AbcSize
end
