after "development:events", "development:unit_memberships" do
  member = UnitMembership.first
  event = Event.last
  event.event_rsvps.create!(unit_membership: member, response: :declined, respondent: member)
end
