# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class EventAttachmentPolicy < UnitContextPolicy
  attr_accessor :event

  def initialize(membership, attachment)
    super
    @membership = membership
    @attachment = attachment
    @event = attachment.record
  end

  def destroy?
    admin? || @membership&.event_organizer? || @event.organizer?(@membership)
  end
end
