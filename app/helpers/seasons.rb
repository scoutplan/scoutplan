# frozen_string_literal: true

# utilities for handling Unit seasons
module Seasons
  def season_month
    8
  end

  def next_season_starts_at
    start_date = Date.today.beginning_of_month + 1.month
    start_date = start_date.advance(months: 1) until start_date.month == 8
    start_date
  end

  def next_season_ends_at
    next_season_starts_at.advance(years: 1)
  end

  def this_season_starts_at
    start_date = Date.today.beginning_of_month
    start_date = start_date.advance(months: -1) until start_date.month == 8
    start_date
  end

  def this_season_ends_at
    this_season_starts_at.advance(years: 1)
  end

  def season_ends_at(start_date = Date.today)
    start_date = start_date.beginning_of_month.advance(months: 1)
    start_date = start_date.advance(months: 1) until start_date.month == season_month
    start_date.advance(days: -1)
  end
end
