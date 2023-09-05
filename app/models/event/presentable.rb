# frozen_string_literal: true

module Event::Presentable
  attr_accessor :plain_text

  def dates_to_s
    return starts_at.strftime("%-d") if single_day?

    "#{starts_at.strftime('%-d')}#{plain_text ? '-' : '&ndash;'}#{ends_at.strftime('%-d')}".html_safe
  end

  def days_to_s
    return starts_at.strftime("%a") if single_day?

    "#{starts_at.strftime('%a')}#{plain_text ? '-' : '&ndash;'}#{ends_at.strftime('%a')}".html_safe
  end

  def single_day?
    starts_at.beginning_of_day == ends_at.beginning_of_day
  end
end
