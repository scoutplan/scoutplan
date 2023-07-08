# frozen_string_literal: true

# Service for handling event organizers
class EventOrganizerService
  attr_accessor :event

  def initialize(event, assigned_by)
    @event = event
    @assigned_by = assigned_by
  end

  def update(event_organizer_params = {})
    event_organizer_params ||= {}
    create_if_needed(event_organizer_params[:unit_membership_ids])
    delete_unused(event_organizer_params[:unit_membership_ids])
  end

  private

  def create_if_needed(member_ids = [])
    member_ids ||= []
    member_ids.each do |member_id|
      event.event_organizers.create_with(assigned_by: @assigned_by).find_or_create_by(unit_membership_id: member_id)
    end
  end

  def delete_unused(member_ids = [])
    member_ids ||= []
    event.event_organizers.each do |event_organizer|
      event_organizer.destroy unless member_ids.include?(event_organizer.unit_membership_id.to_s)
    end
  end
end
