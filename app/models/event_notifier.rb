class EventNotifier
  def rsvp_opening(user)
  end

  # called from EventController when
  # a new event is created
  # def self.new_event(event)
  #   if event.rsvp_open?
  #     new_event_rsvp_open(event)
  #   else
  #     new_event_rsvp_closed(event)
  #   end
  # end

  def self.new_event(event)
    unit = event.unit
    users = unit.members.active
    users.each do |user|
      rsvp_token = RsvpToken.find_by(event: event, user: user)
      EventMailer.with(unit: unit, event: event, user: user, token: rsvp_token).new_event_email.deliver_later

      # enqueue reminders leading up to the event
      [2, 7, 14].each do |days_prior|
        EventMailer.with(unit: unit, event: event, user: user, token: rsvp_token).new_event_email.deliver_later(wait_until: event.starts_at - days_prior.days)
      end

    end
  end

private

end
