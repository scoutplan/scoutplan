# frozen_string_literal: true

# represents a communication from a person to one or more recipients
class Message < ApplicationRecord
  belongs_to :author, class_name: "UnitMembership"
  has_one :unit, through: :author

  validates_presence_of :title

  alias_attribute :member, :unit_membership

  enum status: { draft: 0, queued: 1, sent: 2 }

  serialize :recipient_details, Array

  def event_cohort?
    recipients =~ /event_([0-9]+)_attendees/
  end

  def member_cohort?
    !event_cohort?
  end

  def send_now?
    !send_at&.future?
  end

  private

  def find_unit
    @unit = author.unit
  end
end
