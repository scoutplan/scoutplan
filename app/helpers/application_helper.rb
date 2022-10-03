# frozen_string_literal: true

# application-wide helpers
module ApplicationHelper
  def content_tag_if(tag, conditional, content = nil, options = nil)
    return unless conditional.present?

    content_tag(tag, content || conditional, options)
  end

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

  # given a member, return the appropriate FontAwesome element tag
  def member_glyph_tag(member)
    colors = {
      "youth" => "sky-500",
      "adult" => "pink-500"
    }
    color = colors[member.member_type]

    content_tag :i, nil, class: "fa-user fad mr-1 text-#{color}", title: I18n.t("members.types.#{member.member_type}")
  end

  # given an array of words, return a grammatically correct
  # list, e.g.
  # ['Red'] => "Red"
  # ['Red', 'white'] => "Red and white"
  # ['Red', 'white', 'blue'] => "Red, white, and blue"
  # And, yes, it includes an Oxford comma. Deal with it.
  def list_of_words(words, linking_verb: false)
    return "" unless words

    case words.count
    when 0
      ""
    when 1
      if linking_verb
        "#{words.first}#{words.first.downcase == 'you' ? ' are' : ' is'}"
      else
        words.first
      end
    when 2
      "#{words.first} and #{words.last}#{linking_verb ? ' are' : ''}"
    else
      "#{words[0..-2].join(', ')}, and #{words.last}#{linking_verb ? ' are' : ''}"
    end
  end
end
