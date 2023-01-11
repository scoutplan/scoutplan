# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class EventPolicy < UnitContextPolicy
  attr_accessor :event

  def initialize(membership, event)
    super
    @membership = membership
    @event = event
  end

  def show?
    return true if admin?

    @event.published? && tags_match?
  end

  def edit_rsvps?
    true
  end

  def create?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def rsvps?
    admin? || @membership.event_organizer? || @event.organizers.include?(@membership)
  end

  def organize?
    rsvps?
  end

  def publish?
    admin?
  end

  def rsvp?
    @membership.adult?
  end

  def plan?
    admin?
  end

  def cancel?
    admin?
  end

  def delete?
    destroy?
  end

  def destroy?
    admin?
  end

  private

  # if the event is tagged, does the member possess those tags?
  def tags_match?
    return true if @event.tag_list.empty?

    @membership.tag_list.any? { |tag| @event.tag_list.include?(tag.name) }
  end
end
