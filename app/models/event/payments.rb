module Event::Payments
  extend ActiveSupport::Concern

  def create_reminder_job!
    return unless published? && !ended?

    run_time = starts_at - LEAD_TIME
    run_time = unit.in_business_hours(run_time) if ENV["RAILS_ENV"] == "production"
    EventReminderJob.set(wait_until: run_time).perform_later(id, updated_at)
  end

  def remind!
    return unless published?
    return if ended?

    EventReminderNotification.with(event: self).deliver_later(notification_recipients)
  end

  def family_paid?(member)
    family_amount_due(member).zero?
  end

  # rubocop:disable Metrics/AbcSize
  def family_amount_due(member)
    return @family_ammount_due if @family_ammount_due

    family = member.family
    payments = self.payments.where(unit_membership_id: family.map(&:id))
    family_rsvps = rsvps.where(unit_membership_id: family.map(&:id))
    total_cost = (family_rsvps.accepted.youth.count * cost_youth) + (family_rsvps.accepted.adult.count * cost_adult)
    total_paid = ((payments&.sum(:amount) || 0) / 100)
    @family_amount_due = total_cost - total_paid
  end
  # rubocop:enable Metrics/AbcSize
end
