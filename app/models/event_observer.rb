class EventObserver < ActiveRecord::Observer
  def after_save(event)
    return unless event.requires_rsvp? && event.published?

    # for each active unit member, generate a token and send an email
    event.unit.memberships.active.each do |membership|
      token = event.rsvp_tokens.create(user: membership.user)
      EventMailer.with(token: token).token_invitation_email.deliver_later
    end
  end
end
