class EventRsvpConfirmationText
  attr_accessor :rsvp, :recipient, :event

  def initialize(rsvp, recipient)
    @rsvp = rsvp
    @recipient = recipient
    @event = rsvp.event
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/PerceivedComplexity
  # rubocop:disable Metrics/CyclomaticComplexity
  def to_s
    message = if (recipient == rsvp.unit_membership) == rsvp.respondent
                "We've received your RSVP that you"
              elsif recipient == rsvp.unit_membership
                "#{rsvp.respondent.display_name} has let us know that you"
              else
                "#{rsvp.respondent.first_name} has let us know that they"
              end

    message += if rsvp.accepted?
                 " will be attending"
               elsif rsvp.accepted_pending?
                 " want to attend"
               elsif rsvp.declined?
                 " will not be attending"
               elsif rsvp.declined_pending?
                 " do not plan to attend"
               end

    message += " the #{@event.title}"

    message += if event.single_day?
                 " on #{l event.starts_at, format: '%A, %B %e'}."
               else
                 " from #{l event.starts_at, format: '%A, %B %-e'} to #{l event.ends_at, format: '%A, %B %-e'}."
               end

    return message unless rsvp.pending_approval?

    message += " Their RSVP is tentative until #{member_list(rsvp.approvers, recipient, 'or')} approves it."
    message += " Approve now by visiting "
    message += magic_url_for(@recipient, unit_event_family_rsvps_url(unit, event))
    message += ". RSVPs close #{string_for_time_internal_from_day(event.rsvp_closes_at)}."
    return message unless recipient == rsvp.unit_membership

    "#{message} We've notified them and we'll let you know when your RSVP has been confirmed."
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/PerceivedComplexity
  # rubocop:enable Metrics/CyclomaticComplexity
end
