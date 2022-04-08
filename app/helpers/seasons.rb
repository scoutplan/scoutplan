# frozen_string_literal: true

# utilities for handling Unit seasons
module Seasons
  def next_season_starts_at
    start_date = Date.today.beginning_of_month
    start_date = start_date.advance(months: 1) until start_date.month == 8
    start_date
  end

  def next_season_ends_at
    next_season_starts_at.advance(years: 1)
  end
end
