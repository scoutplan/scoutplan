# frozen_string_literal: true

require "rails_helper"

describe "chats", type: :feature do
  before do
    @member = FactoryBot.create(:member, :youth)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :requires_rsvp, :published, unit: @unit)
    # @event.initiate_chat
    @event.chat.chat_messages.create(author: @member, message: "Hello, world!")
    login_as(@member.user)
  end

  it "visits the event page" do
    visit unit_event_path(@unit, @event)
    expect(page).to have_current_path(unit_event_path(@unit, @event))
  end

  describe "discussion page" do
    before do
      visit unit_event_discussion_index_path(@unit, @event)
    end

    it "displays a new message form" do
      expect(page).to have_content("Hello, world!")
    end
    it "displays a new message form" do
      expect(page).to have_selector("#chat_message_message")
    end
  end
end
