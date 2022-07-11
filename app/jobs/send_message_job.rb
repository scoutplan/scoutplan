# frozen_string_literal: true

# An ActiveJob for sending Messages asynchronously
class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message)
    @message = message
    @members = MessageService.new(@message).resolve_members
    send_to_members
    mark_as_sent
  end

  private

  def send_to_members
    @members.each do |member|
      send_to_member(member)
    end
  end

  def send_to_member(member)
    return unless Flipper.enabled? :messages, member

    MemberNotifier.new(member).send_message(@message)
  end

  def mark_as_sent
    @message.update(status: "sent")
  end
end
