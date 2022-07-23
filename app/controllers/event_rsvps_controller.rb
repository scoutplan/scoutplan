# frozen_string_literal: true

# only intended to be called via XHR...no HTML view exists for this controller
class EventRsvpsController < UnitContextController
  before_action :find_rsvp, only: [:destroy]
  before_action :find_event

  def create
    @service = EventRsvpService.new(current_member)
    @rsvp = @service.create_or_update(params)
    flash[:notice] = I18n.t("events.organize.confirmations.updated_html", name: @rsvp.member.full_display_name)
    # @non_respondents = @event.unit.members.status_active - @event.rsvps.collect(&:member)
    respond_to do |format|
      format.html { redirect_to unit_event_rsvps_path(@unit, @rsvp.event) }
      format.turbo_stream
    end
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
    authorize @rsvp
    event = @rsvp.event
    display_name = @rsvp.full_display_name
    @rsvp.destroy
    redirect_to unit_event_rsvps_path(@unit, event),
                notice: I18n.t("events.organize.confirmations.delete", name: display_name)
  end

  private

  def find_rsvp
    @rsvp = EventRsvp.find(params[:id])
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def find_event_responses
    @non_respondents = @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
    @non_invitees = @event.unit.members - @event.rsvp_tokens.collect(&:member) - @event.rsvps.collect(&:member)
  end
end
