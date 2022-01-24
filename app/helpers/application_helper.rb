# frozen_string_literal: true

# application-wide helpers
module ApplicationHelper
  # rubocop:disable Metrics/MethodLength
  def deictic_day(val)
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

  def pill_tag(text)
    # classes = "text-xs rounded bg-gray-100 text-gray-800 px-2 py-1 mx-2"
    classes = "text-xs font-semibold inline-block text-center text-white bg-gray-600 rounded px-2 py-1 mx-2 min-w-[2rem]"
    content_tag :span, text, class: classes
  end

  def pill_tag_if(condition, text)
    pill_tag(text) if condition
  end
end
