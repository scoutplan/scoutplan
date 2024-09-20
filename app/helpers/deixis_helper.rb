module DeixisHelper
  def temporal_deictic_expression(val)
    return "today" if val.today?
    return "tomorrow" if val.tomorrow?
    return "yesterday" if val.yesterday?
    return "in #{distance_of_time_in_words_to_now(val)}" if val.future?
    return "#{distance_of_time_in_words_to_now(val)} ago" if val.past?

    nil
  end
end
