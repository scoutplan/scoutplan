class EventObserver < ActiveRecord::Observer
  def after_save(event)
    @event = event
    send_invitations if true          &&
      @event.requires_rsvp?           &&
      @event.saved_change_to_status?  &&
      @event.published?
  end

private

  def send_invitations
    @event.unit.memberships.active.each do |membership|
      token = @event.rsvp_tokens.find_or_create_by!(user: membership.user)
      EventMailer.with(token: token).token_invitation_email.deliver_later
    end
  end
end
