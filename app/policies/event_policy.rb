# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class EventPolicy < UnitContextPolicy
  attr_accessor :event, :membership

  def initialize(membership, event = nil)
    super
    @membership = membership
    @event = event
  end

  def show?(event = nil)
    return false unless membership.present?

    @event = event if event.present?
    return true if admin?
    return true if @event.organizer?(@membership)

    @event.published? && tags_match?
  end

  def index?
    true
  end

  def edit_rsvps?
    rsvp? && @event.rsvp_open?
  end

  def create?
    admin?
  end

  def edit?
    admin? || @membership&.event_organizer? || @event.organizer?(@membership)
  end

  def update?
    edit?
  end

  def rsvps?
    admin? || @membership&.event_organizer? || @event.organizer?(@membership)
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

  def view_private_attachments?
    organize?
  end

  private

  # if the event is tagged, does the member possess those tags?
  def tags_match?
    return true if @event.tag_list.empty?
    return true if @membership.nil?

    @membership.tag_list.any? { |tag| @event.tag_list.include?(tag) }
  end
end
