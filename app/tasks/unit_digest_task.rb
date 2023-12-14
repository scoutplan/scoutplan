class UnitDigestTask < UnitTask
  DEFAULT_DAY = :sunday
  DEFAULT_HOUR = 8

  def description
    I18n.t("tasks.unit_digest_description")
  end

  def perform
    Rails.logger.warn { "Sending Unit Digest for #{unit.name}" }

    super

    unit.members.find_each do |member|
      next if member.status_inactive?

      perform_for_member(member)
    end
  end

  def perform_for_member(member)
    Rails.logger.warn { "Sending Unit Digest to #{member.flipper_id}" }
    MemberNotifier.new(member).send_digest
  end

  # set up default schedule for Sunday mornings at 8 AM
  def setup_schedule
    return if schedule_hash.present?

    rule = IceCube::Rule.weekly.day(DEFAULT_DAY).hour_of_day(DEFAULT_HOUR).minute_of_hour(0)
    schedule.start_time = DateTime.now.in_time_zone
    schedule.add_recurrence_rule rule
    save_schedule
  end
end
