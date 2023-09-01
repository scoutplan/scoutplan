# frozen_string_literal: true

class EventInvitation < ApplicationRecord
  belongs_to :event
  belongs_to :unit_membership

  validates_uniqueness_of :event_id, scope: :unit_membership_id

  alias_attribute :member, :unit_membership
end
