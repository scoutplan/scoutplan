require "rails_helper"

RSpec.describe Chat, type: :model do
  it "belongs to a chattable" do
    event = FactoryBot.create(:event)
    chat = FactoryBot.create(:chat, chattable: event)
    expect(chat.chattable).to eq(event)
    expect(event.chat).to eq(chat)
  end

  it "auto-creates a chat when an event is created" do
    event = FactoryBot.create(:event)
    event.initialize_chat
    expect(event.chat).to be_a(Chat)
  end
end
