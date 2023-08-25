# frozen_string_literal: true

class UnitSettings < RailsSettings::SettingObject
  validate do
    errors.add(:base, "must be between 0 and 23") unless (0..23).include?(digest_hour_of_day.to_i)
    errors.add(:base, "must be a valid day of the week") unless weekdays.include?(digest_day_of_week)
  end

  def weekdays
    Date::DAYNAMES.map { |d| d.downcase.to_sym }
  end
end
