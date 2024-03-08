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

  def spans_years?
    starts_at.year != ends_at.year
  end

  def date_to_s_xs(options = {})
    return "#{starts_at.strftime('%b %-d')}#{dash(options)}#{ends_at.strftime('%b %-d, %Y')}".html_safe if spans_months?

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
    return "#{starts_at.strftime('%b %-d')}#{dash(options)}#{ends_at.strftime('%b %-d')}".html_safe if spans_months?
    return "#{starts_at.strftime('%b %-d')}#{dash(options)}#{ends_at.strftime('%-d')}".html_safe if multiday?

    starts_at.strftime("%b %-d")
  end

  # event.dates_to_s => "March 13"
  # event.dates_to_s => "March 13–15"
  # event.dates_to_s => "March 30–April 1"
  # event.dates_to_s => "December 30, 2018—January 2, 2019"

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/LineLength
  def dates_to_s_with_month(**options)
    return "#{starts_at.strftime('%b %-d, %Y')}#{dash(options)}#{ends_at.strftime('%b %-d, %Y')}".html_safe if spans_years?
    return "#{starts_at.strftime('%b %-d')}#{dash(options)}#{ends_at.strftime('%b %-d')}".html_safe if spans_months?
    return "#{starts_at.strftime('%b %-d')}#{dash(options)}#{ends_at.strftime('%-d')}".html_safe if multiday?

    starts_at.strftime("%b %-d")
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/LineLength

  def days_to_s(**options)
    return starts_at.strftime("%a") if single_day?

    "#{starts_at.strftime('%a')}#{dash(options)}#{ends_at.strftime('%a')}".html_safe
  end

  def dash(options)
    options[:plain_text] ? "—" : "&hairsp;&ndash;&hairsp;"
  end
end
