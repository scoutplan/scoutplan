class Time
  def time_of_day
    return 'evening' if hour > 18
    return 'morning' if hour < 12
    return 'afternoon'
  end
end
