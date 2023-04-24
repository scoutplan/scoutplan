# frozen_string_literal: true

require "rails_helper"
require "action_controller"

def render_text_body_to_console(body)
  return
  
  puts
  puts "*********************************"
  puts body
  puts "*********************************"
  puts
end

# rubocop:disable Metrics/BlockLength
RSpec.describe ChatMemberTexter, type: :model do
  before do
    @member = FactoryBot.create(:unit_membership)
    @event = FactoryBot.create(:event, :published, unit: @member.unit, starts_at: 8.hours.from_now)
    @chat = FactoryBot.create(:chat, chattable: @event)
    @chat_message = FactoryBot.create(:chat_message, chat: @chat, author: @member, message: "Hello.")
  end

  it "renders digest from template" do
    texter = ChatMemberTexter.new(@member, @chat_message)
    body = texter.body
    render_text_body_to_console(body)
    expect(body).to include("started a new discussion about")
  end

  it "renders ongoing chats" do
    new_message = FactoryBot.create(:chat_message, chat: @chat, author: @member, message: "Is it me you're looking for?")
    texter = ChatMemberTexter.new(@member, new_message)
    body = texter.body
    render_text_body_to_console(body)

    expect(body).not_to include("started a new discussion about")
    expect(body).to include("asked:")

    new_message = FactoryBot.create(:chat_message, chat: @chat, author: @member, message: "I can see it in your eyes")
    texter = ChatMemberTexter.new(@member, new_message)
    body = texter.body
    render_text_body_to_console(body)
    expect(body).not_to include("asked:")
  end
end
# rubocop:enable Metrics/BlockLength
