# frozen_string_literal: true

# class for displaying Events, specifically
# handling things like single- versus multi-day events,
# events that span month boundaries, etc.
class EventPresenter
  attr_accessor :event, :current_member

  # EventPresenter.new(event: @event, current_member: @current_member)
  def initialize(event = nil, current_member = nil)
    self.event = event
    self.current_member = current_member
  end

  # if family member is current user: "Todd (you)"
  # otherwise: "Chad"
  def family_context_name(member)
    res = member&.display_first_name || ""
    res += " #{I18n.t('you_parenths')}" if current_member == member
    res
  end

  # single day: "13"
  # multi-day: "13–15"
  # spanning month boundary: "31–2"
  def dates_to_s
    return event.starts_at.strftime("%-d") if single_day?

    "#{event.starts_at.strftime('%-d')}&ndash;#{event.ends_at.strftime('%-d')}".html_safe
  end

  # single day: "Friday"
  # multi-day: "Friday–Sunday"
  def days_to_s
    return event.starts_at.strftime("%a") if single_day?

    "#{event.starts_at.strftime('%a')}&ndash;#{event.ends_at.strftime('%a')}".html_safe
  end

  # within same month: "February"
  # spanning month boundary: "February–March"
  def month_name
    if event.starts_at.month != event.ends_at.month
      return "#{event.starts_at.strftime('%B')}&ndash;#{event.ends_at.strftime('%B')}".html_safe
    end

    event.starts_at.strftime("%B")
  end

  def months_and_dates
    return event.starts_at.strftime("%-d %b %Y").html_safe if single_day?

    result = ""
    result += event.starts_at.in_time_zone(current_member.time_zone).strftime("%B")
    result += " " + event.starts_at.in_time_zone(current_member.time_zone).strftime("%-d")
    result += "&ndash;"
    if single_month?
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%-d")
    else
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%B")
      result += " "
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%-d")
    end

    result.html_safe
  end

  def days
    result = event.starts_at.in_time_zone(current_member.time_zone).strftime("%a")
    result += "&ndash;"
    result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%a")
    result.html_safe
  end

  def location
    event.location || event.address
  end

  def full_dates_to_s(show_year: false)
    return event.starts_at.strftime("%A, %-d %b %Y").html_safe if single_day?

    result = event.starts_at.in_time_zone(current_member.time_zone).strftime("%A")
    result += "&ndash;"
    result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%A")
    result += ", " + event.starts_at.in_time_zone(current_member.time_zone).strftime("%B")
    result += " " + event.starts_at.in_time_zone(current_member.time_zone).strftime("%-d")
    result += "&ndash;"
    if single_month?
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%-d")
    else
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%B")
      result += " "
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%-d")
    end

    result += ", #{event.starts_at.strftime("%Y")}" if show_year

    result.html_safe
  end

  def short_dates_to_s
    return event.starts_at.strftime("%a, %b %-d").html_safe if single_day?

    result = event.starts_at.in_time_zone(current_member.time_zone).strftime("%a")
    result += "&ndash;"
    result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%a")
    result += ", " + event.starts_at.in_time_zone(current_member.time_zone).strftime("%b")
    result += " " + event.starts_at.in_time_zone(current_member.time_zone).strftime("%-d")
    result += "&ndash;"
    if single_month?
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%-d")
    else
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%b")
      result += " "
      result += event.ends_at.in_time_zone(current_member.time_zone).strftime("%-d")
    end

    result.html_safe
  end

  # does event span multiple days?
  def single_day?
    event.starts_at.beginning_of_day == event.ends_at.beginning_of_day
  end

  def single_year?
    event.starts_at.year == event.ends_at.year
  end

  def single_month?
    (event.starts_at.month == event.ends_at.month) && single_year?
  end

  def row_classes
    classes  = "event-row"
    classes += " event-#{event.category.name.parameterize}"
    classes += " event-#{event.status}"
    classes += " event-future" if event.starts_at > 3.months.from_now
    classes += " event-past " if event.starts_at.past?
    classes += " event-rsvp" if event.requires_rsvp?

    classes
  end

  # grammatical_list("Garth") => "Garth"
  # grammatical_list("Ebony", "Ivory") => "Ebony and Ivory"
  # grammatical_list("Red", "White", "Blue") => "Red, White, and Blue"
  # and, yes, we use Oxford commas. Accept it.
  def grammatical_list(things)
    return things unless things.is_a?(Array)
    return "" if things.count.zero?
    return things.first if things.count == 1

    [things[0..-2].join(", "), "#{things.count > 2 ? ',' : ''}", " and ", things.last].join
  end

  # returns 'is' or 'are'
  def substantive_verb(things)
    things.count == 1 ? (things.first.downcase == "you" ? "are" : "is") : "are"
  end

  def pluperfect_verb(things)
    things.count == 1 ? (things.first.downcase == "you" ? "has" : "have") : "have"
  end
end
