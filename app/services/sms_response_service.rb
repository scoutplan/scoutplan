# frozen_string_literal: true

# service for handling inbound SMS messages
class SmsResponseService < ApplicationService
  attr_accessor :from, :body, :user, :unit, :member, :event, :context

  def initialize(params)
    self.from = format_phone_number(params[:From])
    self.body = params[:Body].strip.downcase
    super()
  end

  def process
    self.user = user_from_phone
    return unless user.present?

    process_yes_no_response if body_yes_no?
    process_number_response if body_numeric?
  end

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

  def filter_events
    @candidate_events = @candidate_events.reject do |event|
      member = event.unit.members.find_by(user: user)
      rsvp_service = RsvpService.new(member, event)
      rsvp_service.family_fully_responded?
    end
  end

  def find_context
    self.context = ConversationContext.find_by(identifier: from)
  end

  # strips all non-numerics from a string
  def format_phone_number(phone, country_code = "1")
    result = phone.gsub(/\D/, "")
    result = "+#{country_code}#{result}" if result.length == 10
    result
  end

  def process_yes_no_response
    if candidate_events.count == 1
      set_single_event_context
      RsvpService.new(member, event).record_response(body == "yes" ? :accepted : :declined)
      return
    end

    send_event_list if candidate_events.count > 1
  end

  def process_number_response
    ap "Processing number response"
  end

  def query_events
    scope = Event.published.rsvp_required
    scope = scope.where("unit_id IN (?)", user.unit_memberships.collect(&:unit_id))
    scope = scope.where("starts_at BETWEEN ? AND ?", DateTime.now, 30.days.from_now)
    @candidate_events = scope.all
  end

  def record_rsvp
    ap "Recording RSVP to #{event.title} for #{member.full_display_name}"
  end

  def send_confirmation
    ap "Sending #{body} confirmation to #{member.full_display_name} at #{user.phone}"
  end

  def send_event_list
    ConversationContext.create_with(values: { event_ids: candidate_events.collect(&:id) })
                       .find_or_create_by(identifier: from)
    ap candidate_events.map(&:full_title)
  end

  def set_single_event_context
    self.event = candidate_events.first
    self.unit = event.unit
    self.member = unit.members.find_by(user: user)
  end

  # resolve a User from the phone number
  def user_from_phone
    User.find_by(phone: from)
  end
end

# {"ToCountry"=>"US", "ToState"=>"MO", "SmsMessageSid"=>"SM56b5e81897e94acbbac1fc25d4405717", "NumMedia"=>"0",
#  "ToCity"=>"OTTERVILLE", "FromZip"=>"94914", "SmsSid"=>"SM56b5e81897e94acbbac1fc25d4405717", "FromState"=>"CA",
#  "SmsStatus"=>"received", "FromCity"=>"SAN FRANCISCO", "Body"=>"Yes", "FromCountry"=>"US", "To"=>"+16603337175",
#  "ToZip"=>"65348", "NumSegments"=>"1", "ReferralNumMedia"=>"0", "MessageSid"=>"SM56b5e81897e94acbbac1fc25d4405717",
#  "AccountSid"=>"AC898472780113fd79e558e22ce340491a", "From"=>"+14153088236", "putsiVersion"=>"2010-04-01",
#  "controller"=>"inbound_sms", "action"=>"receive"}
