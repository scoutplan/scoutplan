# frozen_string_literal: true

require "rails_helper"

describe "event_tags", type: :feature do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :published, unit: @unit, title: "Untagged Test Event")
    login_as(@member.user, scope: :user)
  end

  it "shows the untagged event" do
    visit list_unit_events_path(@unit)
    expect(page).to have_content(@event.title)
  end

  it "hides the tagged event" do
    @event.tag_list.add("tag1")
    @event.save!
    @event.reload
    visit list_unit_events_path(@unit)
    expect(page).not_to have_content(@event.title)
  end
end
