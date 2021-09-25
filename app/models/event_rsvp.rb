# frozen_string_literal: true

class EventRsvp < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership

  validates_uniqueness_of :event, scope: :unit_membership
  validates_presence_of :response

  enum response: { declined: 0, accepted: 1, accepted_pending: 2 }

  alias_attribute :member, :unit_membership

  delegate :first_name, to: :unit_membership
  delegate :full_name, to: :unit_membership
end
