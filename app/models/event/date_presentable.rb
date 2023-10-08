# frozen_string_literal: true

module Event::DatePresentable
  extend ActiveSupport::Concern

  def duration_in_days
    (ends_at.to_date - starts_at.to_date).to_i
  end

  def multiday?
    duration_in_days.positive?
  end

  def spans_months?
    starts_at.month != ends_at.month
  end
end