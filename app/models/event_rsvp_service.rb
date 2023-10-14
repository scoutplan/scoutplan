# frozen_string_literal: true

class EventRsvpService
  attr_accessor :target_member, :event

  def initialize(member)
    @member = member
  end

  def find_or_create_rsvp(**args)
    event      = args[:event]
    member     = args[:member]
    response   = args[:response]
    respondent = args[:respondent]

    event.rsvps.find_or_create_by(unit_membership: member) do |rsvp|
      rsvp.respondent = respondent
      rsvp.response = enforce_approval_policy(respondent, response)
    end
  end

  private

  def enforce_approval_policy(respondent, response)
    return unless respondent.youth?

    case response
    when "accepted" then "accepted_pending"
    when "declined" then "declined_pending"
    else response
    end
  end
end
