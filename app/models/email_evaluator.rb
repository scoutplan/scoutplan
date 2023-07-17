# frozen_string_literal: true

require "openai"

# The EmailEvaluator is responsible for analyzing the email to determine the appropriate mailbox
# to route to. It is used by the ApplicationMailbox.
class EmailEvaluator
  AUTO_RESPONDER_HEADER = "Auto-Submitted"
  AUTO_RESPONDER_VALUES = %w[auto-replied auto-generated].freeze
  EVENT_REGEX = /event-(.+)@.*/
  AI_PROMPT = <<~PROMPT
    We are planning an event and receiving responses via email.
    From the following email text, extract the name of the event and then generate a
    table of people, including me, and whether they're attending:
  PROMPT

  attr_reader :event, :unit, :slug, :modifier

  def initialize(inbound_email)
    @mail = inbound_email.mail
    evaluate
  end

  # returns true if the email is an auto-responder
  def auto_responder?
    return false unless (val = @mail.header[AUTO_RESPONDER_HEADER].present?)

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
    local = to_address.split("@").first
    local_parts = local.split(".")

    @user = User.find_by(email: from_address)
    @slug = local_parts.first
    @modifier = local_parts.drop(1)
    @unit ||= Unit.find_by(slug: @slug)
    @member = @user.unit_memberships.where(unit: @unit)

    perform_ai_parsing if ai_parseable?
  end

  def find_event
    @mail.to.first.match(EVENT_REGEX) do |m|
      event_uuid = m[1]
      @event = Event.find_by(uuid: event_uuid)
      @unit = @event&.unit
    end
  end

  def perform_ai_parsing
    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
    response = client.completions(
      parameters: {
        model: "text-davinci-003",
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

      ap "#{name} is #{attending ? 'attending' : 'not attending'}"
    end
  end
end

# We are planning an event and receiving responses via email. From the following email text, generate a table of people, including me, and whether they're attending:

# Timmy, Taylor, and I will be there. Sally can't make it.