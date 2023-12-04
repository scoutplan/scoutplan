class UnitSettings < RailsSettings::SettingObject
  validate do
    errors.add(:base, "must be between 0 and 23") unless (0..23).include?(digest_hour_of_day.to_i)
    if digest_day_of_week.present? && !weekdays.include?(digest_day_of_week)
      errors.add(:base, "must be a valid day of the week")
    end
  end

  def weekdays
    Date::DAYNAMES.map { |d| d.downcase.to_sym }
  end
end
