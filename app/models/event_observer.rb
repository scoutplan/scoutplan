class EventObserver < ActiveRecord::Observer
  # def after_update(event)
  #   send_notifications(event)
  # end

  def after_save(event)
    send_notifications(event)
  end

private

  # for each active unit member, generate a token and send an email
  def send_notifications(event)
    return unless event.requires_rsvp? && event.published?

    event.unit.memberships.active.each do |membership|
      token = event.rsvp_tokens.find_or_create_by!(user: membership.user)
      EventMailer.with(token: token).token_invitation_email.deliver_later
    end
  end
end
