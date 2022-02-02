# frozen_string_literal: true

# application-wide helpers
module ApplicationHelper
  # rubocop:disable Metrics/MethodLength
  def deictic_string_for_time_interval_from_day(val)
    if val.today?
      "today"
    elsif val.tomorrow?
      "tomorrow"
    elsif val.yesterday?
      "yesterday"
    elsif val.future?
      "#{distance_of_time_in_words_to_now(val)} from now"
    elsif val.past?
      "#{distance_of_time_in_words_to_now(val)} ago"
    end
  end
  # rubocop:enable Metrics/MethodLength

  def pill_tag(text, additional_classes = nil)
    additional_classes ||= "text-white bg-gray-600"
    classes = "text-xs font-semibold inline-block text-center rounded px-2 py-1 mx-2 min-w-[2rem]"
    classes = [classes, additional_classes].join(" ")
    content_tag :span, text, class: classes
  end

  def pill_tag_if(condition, text)
    pill_tag(text) if condition
  end

  # given a member, return the appropriate FontAwesome element tag
  def member_glyph_tag(member)
    colors = {
      "youth" => "sky-500",
      "adult" => "pink-500"
    }
    color = colors[member.member_type]

    content_tag :i, nil, class: "fa-user fad mr-2 text-#{color}", title: I18n.t("members.types.#{member.member_type}")
  end
end