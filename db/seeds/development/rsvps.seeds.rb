# frozen_string_literal: true

after 'development:events', 'development:users' do
  user  = User.first
  event = Event.last

  event.event_rsvps.create(user: user, response: :declined)
end
