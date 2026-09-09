# frozen_string_literal: true

require "rails_helper"

describe "the event show layout", type: :feature do
  before do
    @admin = FactoryBot.create(:member, :admin)
    @unit = @admin.unit
  end

  def bare_event
    event = FactoryBot.create(:event, :published, unit: @unit, requires_rsvp: false,
      cost_adult: 0, cost_youth: 0, description: nil)
    event.event_locations.destroy_all
    event
  end

  describe "when nothing would fill the rail" do
    before do
      login_as(@admin.user, scope: :user)
      visit unit_event_path(@unit, bare_event)
    end

    it "omits the aside entirely rather than leaving an empty column" do
      expect(page).to have_no_css("#event_rail")
    end

    it "holds the content to a readable measure" do
      expect(page).to have_css("div.max-w-3xl")
    end
  end

  describe "when the rail has something in it" do
    before do
      @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit)
      login_as(@admin.user, scope: :user)
      visit unit_event_path(@unit, @event)
    end

    it "renders the aside" do
      expect(page).to have_css("#event_rail")
    end

    it "leaves the content column full width" do
      expect(page).to have_no_css("div.max-w-3xl")
    end
  end

  describe "the empty description prompt" do
    it "invites someone who can edit to write one" do
      login_as(@admin.user, scope: :user)

      visit unit_event_path(@unit, bare_event)

      expect(page).to have_link("Add a description")
    end

    it "shows nothing at all to someone who cannot edit" do
      member = FactoryBot.create(:member, unit: @unit)
      login_as(member.user, scope: :user)

      visit unit_event_path(@unit, bare_event)

      expect(page).to have_no_content("Add a description")
      expect(page).to have_no_css("#narrative")
    end

    it "yields to a real description once there is one" do
      event = bare_event
      event.update!(description: "Bring a bag lunch.")
      login_as(@admin.user, scope: :user)

      visit unit_event_path(@unit, event)

      expect(page).to have_content("Bring a bag lunch.")
      expect(page).to have_no_link("Add a description")
    end
  end
end
