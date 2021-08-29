class ScoutplanUtilities
  def self.compose_datetime(date_str, time_str)
    str = "#{date_str} #{time_str}"
    # fmt = "%Y-%m-%d %H:%M:%S"
    # DateTime.strptime(str, fmt)
    DateTime.parse(str)
  end
end
