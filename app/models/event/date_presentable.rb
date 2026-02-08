# frozen_string_literal: true

module Event::DatePresentable
  extend ActiveSupport::Concern

  def duration_in_days
    (ends_at.to_date - starts_at.to_date).to_i
  end

  def multiday?
    duration_in_days.positive?
  end

  def single_day?
    !multiday?
  end

  def spans_months?
    starts_at.month != ends_at.month
  end

  def date_to_s_xs(options = {})
    return "#{starts_at.strftime('%b %-d')}#{dash(options)}#{ends_at.strftime('%b %-d, %Y')}".html_safe if spans_months?
    return starts_at.strftime("%b %-d, %Y") if single_day?

    "#{starts_at.strftime('%b %-d')}#{dash(options)}#{ends_at.strftime('%-d, %Y')}"
  end

  def date_to_s_short(options = {})
    return "#{starts_at.strftime('%B %-d')}#{dash(options)}#{ends_at.strftime('%B %-d, %Y')}".html_safe if spans_months?

    "#{starts_at.strftime('%B %-d')}#{dash(options)}#{ends_at.strftime('%-d, %Y')}"
  end

  def date_to_s(**options)
    return date_to_s_short(options) if options[:format] == :short
    return starts_at.strftime("%A, %B %-d, %Y") if single_day?

    "#{starts_at.strftime('%A, %B %-d')}#{dash(options)}#{ends_at.strftime('%A, %B %-d, %Y')}".html_safe
  end

  # single day: "13"
  # multi-day: "13–15"
  # spanning month boundary: "31–2"
  def dates_to_s(**options)
    return starts_at.strftime("%-d") if single_day?

    "#{starts_at.strftime('%-d')}#{dash(options)}#{ends_at.strftime('%-d')}".html_safe
  end

  def days_to_s(**options)
    return starts_at.strftime("%a") if single_day?

    "#{starts_at.strftime('%a')}#{dash(options)}#{ends_at.strftime('%a')}".html_safe
  end

  def dash(options)
    options[:plain_text] ? "—" : "&hairsp;&ndash;&hairsp;"
  end
end
