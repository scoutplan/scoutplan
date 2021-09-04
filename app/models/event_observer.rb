class EventObserver < ActiveRecord::Observer
  def after_save(event)
    return unless event.requires_rsvp

    puts event.rsvp_tokens.count

    event.rsvp_tokens.each do |token|
      puts 'Sending ' + token.value
      EventMailer.with(token: token).invitation_email.deliver_later
    end
  end
end
