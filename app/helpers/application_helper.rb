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
end
