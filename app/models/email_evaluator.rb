# frozen_string_literal: true

require "openai"

# The EmailEvaluator is responsible for analyzing the email to determine the appropriate mailbox
# to route to. It is used by the ApplicationMailbox.
class EmailEvaluator
  AUTO_RESPONDER_HEADER = "Auto-Submitted"
  AUTO_RESPONDER_VALUES = %w[auto-replied auto-generated].freeze
  AI_PROMPT = "Extract the names of people and whether they're attending from the email text below.\n\nText: "

  attr_reader :unit, :slug, :modifier

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

  def evaluate
    sender = @mail.to.first.split("@").first
    sender_parts = sender.split(".")
    @slug = sender_parts.first
    @modifiers = sender_parts.drop(1)
    @unit = Unit.find_by(slug: @slug)
    prompt = "#{AI_PROMPT}\n\nText: #{@mail.body}"

    ap prompt

    client = OpenAI::Client.new(access_token: ENV.fetch("OPENAI_ACCESS_TOKEN"))
    response = client.completions(
      parameters: {
        model: "text-davinci-003",
        prompt: prompt,
        temperature: 0,
        max_tokens: 1000
      }
    )

    ap response
  end
end
