# frozen_string_literal: true

# Service class for displaying Events, specifically
# handling things like single- versus multi-day events,
# events that span month boundaries, etc.

# rubocop:disable Metrics/ClassLength
class EventPresenter
  include ActionView::Helpers

  attr_accessor :event, :current_member, :plain_text

  # EventPresenter.new(event: @event, current_member: @current_member)
  def initialize(event = nil, current_member = nil, plain_text: false)
    self.event = event
    self.current_member = current_member
    self.plain_text = plain_text
  end

  # if family member is current user: "Todd (you)"
  # otherwise: "Chad"
  def family_context_name(member)
    res = member&.display_first_name || ""
    res += " #{I18n.t('you_parenths')}" if current_member == member
    res
  end

  def cost
    return "#{number_to_currency(event.cost_youth)} per person" if event.cost_youth == event.cost_adult

    "#{number_to_currency(event.cost_youth)} per youth, #{number_to_currency(event.cost_adult)} per adult"
  end

  # single day: "13"
  # multi-day: "13–15"
  # spanning month boundary: "31–2"
  def dates_to_s
    return event.starts_at.strftime("%-d") if single_day?

    "#{event.starts_at.strftime('%-d')}#{plain_text ? '-' : '&ndash;'}#{event.ends_at.strftime('%-d')}".html_safe
  end

  # single day: "Friday"
  # multi-day: "Friday–Sunday"
  def days_to_s
    return event.starts_at.strftime("%a") if single_day?

    "#{event.starts_at.strftime('%a')}#{plain_text ? '-' : '&ndash;'}#{event.ends_at.strftime('%a')}".html_safe
  end

  # within same month: "February"
  # spanning month boundary: "February–March"
  # rubocop:disable Metrics/AbcSize
  def month_name
    result = event.starts_at.strftime("%B")
    result.concat "#{ndash}#{event.ends_at.strftime('%B')}" unless single_month?
    result.concat " #{event.starts_at.strftime('%Y')}" unless event.starts_at.year == Date.today.year
    result.html_safe
  end
  # rubocop:enable Metrics/AbcSize

  # rubocop:disable Metrics/AbcSize
  # single day: "13 February 2015"
  # multi-day: "13–15 February 2015"
  # spanning month boundary: "31 January–2 February 2015"
  def months_and_dates
    return event.starts_at.strftime("%-d %b %Y").html_safe if single_day?

    result = event.starts_at.in_time_zone(current_member.time_zone).strftime("%B %-d")
    result.concat ndash
    result.concat "#{event.ends_at.in_time_zone(current_member.time_zone).strftime('%B')} " unless single_month?
    result.concat event.ends_at.in_time_zone(current_member.time_zone).strftime("%-d")

    result.html_safe
  end
  # rubocop:enable Metrics/AbcSize

  def ndash
    @plain_text ? "-" : "&ndash;"
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

  # single day: "Friday, 13 February 2015"
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
    classes += " event-past " if event.past?
    classes += " event-rsvp" if event.requires_rsvp?

    classes
  end
end
# rubocop:enable Metrics/ClassLength
