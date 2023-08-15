# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class EventPolicy < UnitContextPolicy
  attr_accessor :event

  def initialize(membership, event)
    super
    @membership = membership
    @event = event
  end

  def show?(event = nil)
    @event = event if event.present?
    return true if admin?
    return true if @event.organizer?(@membership)

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
    admin? || @membership.event_organizer? || @event.organizer?(@membership)
  end

  def nope?
    false
  end

  def organize?
    rsvps?
  end

  def publish?
    admin?
  end

  def rsvp?
    rsvp = EventRsvp.new(event: @event, unit_membership: @membership)
    EventRsvpPolicy.new(@membership, rsvp).create?

    # return true if @membership.adult?
    # return true if @membership.youth? && @membership.allow_youth_rsvps? && @event.unit.allow_youth_rsvps? && @event.allow_youth_rsvps?
    # false
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

  def view_drafts?
    admin?
  end

  private

  # if the event is tagged, does the member possess those tags?
  def tags_match?
    return true if @event.tag_list.empty?

    @membership.tag_list.any? { |tag| @event.tag_list.include?(tag) }
  end

end
