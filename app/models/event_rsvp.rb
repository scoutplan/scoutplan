# frozen_string_literal: true

# a response, from a Member (aka UnitMembership), to an Event
class EventRsvp < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership
  belongs_to :respondent, class_name: 'UnitMembership'

  validates_uniqueness_of :event, scope: :unit_membership
  validates_presence_of :response
  validate :common_unit?

  enum response: { declined: 0, accepted: 1, accepted_pending: 2 }

  alias_attribute :member, :unit_membership

  delegate :first_name, to: :unit_membership
  delegate :full_name, to: :unit_membership
  delegate :display_first_name, to: :unit_membership
  delegate :user, to: :unit_membership
  delegate :unit, to: :unit_membership
  delegate :contactable?, to: :unit_membership

  # do the Event and UnitMembership share a Unit in common?
  # if not, something's wrong
  def common_unit?
    errors.add(:event, 'and Member must belong to the same Unit') unless event.unit == member.unit
  end
end
