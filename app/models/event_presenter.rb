# frozen_string_literal: true

class EventPresenter
  attr_accessor :event

  def initialize(**options)
    options.each do |k, v|
      instance_variable_set("@#{k}", v) unless v.nil?
    end
  end

  def category_to_fa_glyph(category)
    case category
    when 'camping'
      'fas fa-campground'
    when 'troop_meeting'
      'fas fa-users'
    when 'court_of_honor'
      'fas fa-medal'
    end
  end

  def family_context_name(user)
    res = user&.first_name || ''
    res += " #{I18n.t('you_parenths')}" if @current_user == user
    res
  end

  def dates_to_s
    return @event.starts_at.strftime('%-d') if is_single_day?

    "#{@event.starts_at.strftime('%-d')}&ndash;#{@event.ends_at.strftime('%-d')}".html_safe
  end

  def days_to_s
    return @event.starts_at.strftime('%a') if is_single_day?

    "#{@event.starts_at.strftime('%a')}&ndash;#{@event.ends_at.strftime('%a')}".html_safe
  end

  def month_name
    if @event.starts_at.month != @event.ends_at.month
      return "#{@event.starts_at.strftime('%B')}&ndash;#{@event.ends_at.strftime('%B')}".html_safe
    end

    @event.starts_at.strftime('%B')
  end

  def location
    @event.location
  end

  def full_dates_to_s
    return html_safe(@event.starts_at.strftime('%A, %d %b %Y')) if is_single_day?

    html_safe(@event.starts_at.strftime('%A, %b %d'))
  end

  def is_single_day?
    @event.starts_at.year == @event.ends_at.year && @event.starts_at.day == @event.ends_at.day
  end

  def row_classes
    classes  = 'event-row'
    classes += " event-#{@event.category.name.parameterize}"
    classes += " event-#{@event.status}"
    classes += ' event-future' if @event.starts_at > 3.months.from_now
    classes += ' event-past ' if @event.starts_at.past?
    classes += ' event-rsvp' if @event.requires_rsvp?

    classes
  end
end
