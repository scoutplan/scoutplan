require "active_model/attribute_assignment"

# Form object behind the Cancel Event dialog: applies the chosen disposition to the event (and,
# when asked, the rest of its series) and notifies the chosen audience.
class EventCancellation
  include ActiveModel::AttributeAssignment

  DISPOSITIONS = %w[cancel unpublish delete].freeze

  attr_reader :event
  attr_accessor :message_audience, :message, :cancel_series, :disposition

  def initialize(event)
    @event = event
  end

  def events
    list = [event]
    list.concat(event.series.where("starts_at > ?", event.starts_at).to_a) if cancel_series? && event.series?
    list
  end

  # "Leave on calendar as cancelled" is the safe choice when nothing was picked: it is reversible
  # and keeps the event visible to members, unlike delete or unpublish.
  def disposition
    DISPOSITIONS.include?(@disposition.to_s) ? @disposition.to_s : "cancel"
  end

  def cancel_series?
    ActiveModel::Type::Boolean.new.cast(cancel_series) || false
  end

  # Returns true when every event was updated. Notifications go out first so a deleted event can
  # still be described; they carry the title and date rather than the record for the same reason.
  def cancel!
    notify
    events.map { |e| apply_disposition(e) }.all?
  end

  # Memoized so the list survives the disposition (a deleted event has no RSVPs left to read).
  def recipients
    @recipients ||= find_recipients.uniq
  end

  private

  def find_recipients
    return [] if event.draft?

    case message_audience.to_s
    when "acceptors"
      event.rsvps.accepted.includes(:unit_membership).map(&:unit_membership)
    when "active_members"
      unit.members.contactable?.status_active.to_a
    when "all_members"
      unit.members.contactable?.status_active_and_registered.to_a
    else
      []
    end
  end

  def unit
    event.unit
  end

  def notify
    return if recipients.empty?

    EventCancellationNotifier.with(
      unit:      unit,
      title:     event.title,
      starts_at: event.starts_at,
      note:      message.presence
    ).deliver(recipients)
  end

  def apply_disposition(target)
    case disposition
    when "cancel"
      target.update(status: :cancelled)
    when "unpublish"
      target.update(status: :draft)
    when "delete"
      target.destroy
    end
  end
end
