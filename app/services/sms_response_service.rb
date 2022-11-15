# frozen_string_literal: true

require "twilio-ruby"
require "json"

# service for handling inbound SMS messages
class SmsResponseService < ApplicationService
  attr_accessor :from, :body, :user, :context, :params, :request

  def initialize(params, request)
    self.request = request
    self.params = params
    self.from = params["From"]
    self.body = params["Body"].strip.downcase.gsub(/\W/, "")
    super()
  end

  def process
    return unless valid_request?

    resolve_user_from_phone
    return unless user.present?

    Rails.logger.info "Processing SMS response from #{from} with body #{body} for user_id #{user.id}"

    case response_classification
    when :rsvp_response
      process_rsvp_response
    when :choose_item
      process_numeric_response
    when :prompt_upcoming_event
      prompt_upcoming_event
    else
      send_event_list
    end
  end

  #-------------------------------------------------------------------------
  private

  def body_numeric?
    body.to_i.positive?
  end

  def body_yes_no?
    %w[yes no].include?(body)
  end

  # for a given user, determine what events are pending
  def candidate_events
    return @candidate_events if @candidate_events.present?

    query_events
    filter_events
    @candidate_events
  end

  def conversation_context
    @context ||= @context = ConversationContext.find_by(identifier: from)
  end

  def candidate_event
    user.events.published.future.rsvp_required.first
  end

  def family
    member.family
  end

  def filter_events
    @candidate_events = @candidate_events.reject do |event|
      member = event.unit.members.find_by(user: user)
      rsvp_service = RsvpService.new(member, event)
      rsvp_service.family_fully_responded?
    end

    # TEMPORARY
    @candidate_events = [@candidate_events&.first]
  end

  def member
    @member || @member = unit.members.find_by(user: user)
  end

  def process_numeric_response
    ap "Processing number response"
  end

  # if a yes/no response is received, process it
  def process_rsvp_response
    prompt_upcoming_event and return if conversation_context.nil?

    values = JSON.parse(conversation_context.values)
    event = Event.find(values["event_id"])
    member_ids = values["members"]
    member_ids.each { |member_id| process_rsvp(event, member_id) }
    reset_context
    MemberNotifier.new(member).send_rsvp_confirmation(event)
  end

  # process a yes/no for a single member. Called by #process_rsvp_response
  def process_rsvp(event, member_id)
    family_member = event.unit.members.find(member_id)
    response = (body == "yes") ? "accepted" : "declined"
    rsvp = EventRsvp.find_by(event: event, unit_membership: family_member)
    if rsvp.present?
      rsvp.update(response: response)
    else
      rsvp = EventRsvp.create(event: event, unit_membership: family_member, response: response, respondent: member)
    end
    rsvp
  end

  # compute next event needing a response and SMS it to the user
  def prompt_upcoming_event
    reset_context
    member_ids = family.select{ |m| m.status_active? }.map(&:id)
    values = { "type" => "event",
               "event_id" => candidate_event.id,
               "members" => member_ids }
    ConversationContext.create!(identifier: from, values: values.to_json)
    UserNotifier.new(user).prompt_upcoming_event(candidate_event)
  end

  def query_events
    scope = Event.published.rsvp_required
    scope = scope.where("unit_id IN (?)", user.unit_memberships.collect(&:unit_id))
    scope = scope.where("starts_at BETWEEN ? AND ?", DateTime.now, 30.days.from_now)
    @candidate_events = scope.all
  end

  def reset_context
    ConversationContext.find_by(identifier: from)&.destroy
  end

  # what's the user trying to do?
  def response_classification
    return :prompt_upcoming_event if %w[upcoming next].include?(body)
    return :choose_item if body_numeric?
    return :rsvp_response if body_yes_no?
    return :list_events if %w[events list].include?(body)

    :unknown
  end

  # given the current phone, find the User
  def resolve_user_from_phone
    self.user = User.find_by(phone: from)
  end

  # if >1 candidate events, send a list for disambiguation
  def send_event_list
    UserNotifier.new(user).send_event_list
  end

  def unit
    @unit || @unit = candidate_event.unit
  end

  def valid_request?
    return true if ENV["RAILS_ENV"] == "test"

    signature = request.headers["X-Twilio-Signature"]
    return false unless signature.present?

    validator = Twilio::Security::RequestValidator.new(ENV["TWILIO_TOKEN"])
    url = request.url
    signature = request.headers["X-Twilio-Signature"]

    validator.validate(url, validation_params, signature)
  end

  def validation_params
    request.params.reject { |k, _v| k == "controller" || k == "action" }
  end
end
