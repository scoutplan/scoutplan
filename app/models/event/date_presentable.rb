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

  def date_to_s
    return starts_at.strftime("%A, %B %-d, %Y") if single_day?

    "#{starts_at.strftime('%A, %B %-d')}&hairsp;&ndash;&hairsp;#{ends_at.strftime('%A, %B %-d, %Y')}".html_safe
  end

  def spans_months?
    starts_at.month != ends_at.month
  end
end
