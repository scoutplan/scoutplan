after :events do
  user = User.first
  event = Event.last

  event.event_rsvps.create(user: user)
end
