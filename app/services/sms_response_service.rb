# frozen_string_literal: true

require "twilio-ruby"

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
      process_yes_no_response
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

  def event
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

  def find_context
    self.context = ConversationContext.find_by(identifier: from)
  end

  def member
    unit.members.find_by(user: user)
  end

  def process_numeric_response
    ap "Processing number response"
  end

  def process_yes_no_response
    if candidate_events.count == 1
      RsvpService.new(member, event).record_family_response(body == "yes" ? :accepted : :declined)
      return
    end

    send_event_list if candidate_events.count > 1
  end

  def prompt_upcoming_event
    reset_context
    values = { "type" => "event", "members" => family.map(&:id), "index" => 0 }
    ConversationContext.create(identifier: from, values: values)
    UserNotifier.new(user).prompt_upcoming_event(event)
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
    event.unit
  end

  def valid_request?
    # true

    return true if ENV["RAILS_ENV"] == "test"

    signature = request.headers["X-Twilio-Signature"]
    return false unless signature.present?

    validator = Twilio::Security::RequestValidator.new(ENV["TWILIO_TOKEN"])
    url = request.url
    signature = request.headers["X-Twilio-Signature"]

    ap ENV["TWILIO_TOKEN"]
    ap url
    ap signature
    ap validation_params

    res = validator.validate(url, validation_params, signature)
    ap res
    res
  end

  def validation_params
    request.params.reject { |k, _v| k == "controller" || k == "action" }
  end
end

# {"ToCountry"=>"US", "ToState"=>"MO", "SmsMessageSid"=>"SM56b5e81897e94acbbac1fc25d4405717", "NumMedia"=>"0",
#  "ToCity"=>"OTTERVILLE", "FromZip"=>"94914", "SmsSid"=>"SM56b5e81897e94acbbac1fc25d4405717", "FromState"=>"CA",
#  "SmsStatus"=>"received", "FromCity"=>"SAN FRANCISCO", "Body"=>"Yes", "FromCountry"=>"US", "To"=>"+16603337175",
#  "ToZip"=>"65348", "NumSegments"=>"1", "ReferralNumMedia"=>"0", "MessageSid"=>"SM56b5e81897e94acbbac1fc25d4405717",
#  "AccountSid"=>"AC898472780113fd79e558e22ce340491a", "From"=>"+14153088236", "putsiVersion"=>"2010-04-01",
#  "controller"=>"inbound_sms", "action"=>"receive"}
