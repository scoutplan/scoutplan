# frozen_string_literal: true

# only intended to be called via XHR...no HTML view exists for this controller
class EventRsvpsController < UnitContextController
  def create
    service = EventRsvpService.new(current_member)
    rsvp = service.create_or_update(params)
    flash[:notice] = I18n.t("events.organize.confirmations.updated_html", name: rsvp.member.full_display_name)
    redirect_to unit_event_organize_path(@unit, rsvp.event)
  end

  # send or re-send an invitation
  def invite
    @event = Event.find(params[:id])
    @member = UnitMembership.find(params[:member_id])
    @token  = @event.rsvp_tokens.create!(unit_membership: @member)
    EventNotifier.invite_member_to_event(@token)
    find_event_responses
    respond_to :js
  end

  def destroy
    rsvp = EventRsvp.find(params[:id])
    unit = rsvp.unit
    event = rsvp.event
    target_member = rsvp.member
    @member = unit.membership_for(current_user)
    authorize rsvp
    flash[:notice] = I18n.t("events.organize.confirmations.delete", name: target_member.full_display_name)
    rsvp.destroy
    redirect_to unit_event_organize_path(unit, event)
  end

  def pundit_user
    @member
  end

  private

  def find_event_responses
    @non_respondents = @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
  end
end
