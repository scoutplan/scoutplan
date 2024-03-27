# frozen_string_literal: true

require "openai"

# https://local.scoutplan.org/rails/conductor/action_mailbox/inbound_emails
class EmailEvaluator
  AUTO_RESPONDER_HEADER = "Auto-Submitted"
  AUTO_RESPONDER_VALUES = %w[auto-replied auto-generated].freeze
  REGEXP_EVENT   = /event-(.+)@.*/
  REGEXP_MESSAGE = /message-(.+)@.*/
  AI_PROMPT = <<~PROMPT
    We are planning an event and receiving responses via email.
    From the following email text, extract the name of the event and then generate a
    table of people, including me, and whether they're attending:
  PROMPT

  attr_reader :event, :unit, :slug, :modifier, :message

  def initialize(inbound_email)
    @mail = inbound_email.mail
    evaluate
  end

  # returns true if the email is an auto-responder
  def auto_responder?
    val = @mail.header[AUTO_RESPONDER_HEADER]
    return false unless val.present?

    AUTO_RESPONDER_VALUES.include?(val.value)
  end

  # returns true if a unit is found from the email address
  def unit?
    @unit.present?
  end

  private

  # Should the event be parsed by AI? It costs money
  # so we should only do it if we can get meaningful insights
  def ai_parseable?
    @event.present? && Flipper.enabled?(:ai_event_parsing)
  end

  def ai_prompt
    "#{AI_PROMPT}\n\nText: #{@mail.body}"
  end

  def evaluate
    to_address = @mail.to.first
    from_address = @mail.from.first

    find_event
    find_message
    local = to_address.split("@").first
    local_parts = local.split(".")

    @user = User.find_by(email: from_address)
    @slug = local_parts.first

    @modifier = local_parts.drop(1)
    @unit ||= Unit.find_by(slug: @slug)

    return unless @user.present? && @unit.present?

    @member = @user.unit_memberships.where(unit: @unit)

    perform_ai_parsing if ai_parseable?
  end

  def find_event
    @mail.to.first.match(REGEXP_EVENT) do |m|
      event_token = m[1]
      @event = Event.find_by(token: event_token)
      @unit = @event&.unit
    end
  end

  def find_message
    @mail.to.first.match(REGEXP_MESSAGE) do |m|
      message_token = m[1]
      @message = Message.find_by(token: message_token)
      @unit = @message&.unit
    end
  end

  def perform_ai_parsing
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
    response = client.completions(
      parameters: {
        model: "gpt-3.5-turbo-instruct",
        prompt: ai_prompt,
        temperature: 0,
        max_tokens: 1000
      }
    )

    return unless response["choices"].present?

    response_text = response["choices"].first["text"]
    response_lines = response_text.split("\n")
    response_lines.each do |line|
      line_parts = line.split(" | ")
      next unless line_parts.length == 2

      name = line_parts.first
      attending = line_parts.last != "No"
    end
  end
end

# We are planning an event and receiving responses via email. From the following email text, generate a table of people, including me, and whether they're attending:

# Timmy, Taylor, and I will be there. Sally can't make it.