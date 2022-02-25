# frozen_string_literal: true

# an ephemeral (not persisted) class for encapsulating event cancellations
class EventCancellation < ActiveModel::Model
  enum notification_recipients: { none: 0, attendees: 1, active: 2, everyone: 4 }
  attr_accessor :note
end
