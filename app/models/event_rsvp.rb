# frozen_string_literal: true

# a response, from a Member (aka UnitMembership), to an Event
class EventRsvp < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership
  belongs_to :respondent, class_name: "UnitMembership"

  has_many :documents, as: :documentable, dependent: :destroy

  validates_uniqueness_of :event, scope: :unit_membership
  validates_presence_of :response
  validate :common_unit?

  enum response: { declined: 0, accepted: 1, accepted_pending: 2 }

  alias_attribute :member, :unit_membership

  delegate_missing_to :unit_membership

  scope :ordered, -> { includes(unit_membership: :user).order("users_unit_memberships.last_name, users_unit_memberships.first_name") }

  # do the Event and UnitMembership share a Unit in common?
  # if not, something's wrong
  def common_unit?
    errors.add(:event, "and Member must belong to the same Unit") unless event.unit == member.unit
  end

  def document?(document_type)
    documents.find_by(document_type: document_type)
  end
end
