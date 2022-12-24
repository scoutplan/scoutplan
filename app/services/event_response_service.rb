# frozen_string_literal: true

# a serivce object to handle the response to an event
# usage:
# responses = [{ member: member1, response: "attending" }, { member: member2, response: "declined" }]
# EventResponseService.new(event).process(@current_member, responses)
# called from:
# 1. Event web page
# 2. Event Organize page
# 3. SMS processing
class EventResponseService < ApplicationService
  def initialize(event)
    @event = event
    super
  end

  # process(member, [{ member: member1, response: "attending" }, { member: member2, response: "declined" }}])
  def process(respondent, responses = [])
    return unless @event.requires_rsvp
    return unless respondent.present? && responses.any?

    @respondent = respondent
    @responses = responses
    responses.each do |response|
      process_response(response)
    end

    notify_members
  end

  private

  # e.g. process(member1, "attending")
  def process_response(member, response)
    return unless response.present?

    rsvp = EventRsvp.find_or_initialize_by(event: @event, unit_membership: member)
    rsvp.update(response: response, respondent: @respondent)
  end

  def notify_members
    @responses.each do |response|
      member = response[:member]
      next unless member.contactable?

      MemberNotifier.new(member).send_rsvp_confirmation(@event)
    end
  end
end
