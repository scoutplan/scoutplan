# frozen_string_literal: true

require "rails_helper"

describe "event show header", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :published, unit: @unit, title: "Troop Meeting")
    login_as(@member.user, scope: :user)
  end

  def attach_cover_photo
    @event.cover_photo.attach(
      io: File.open(Rails.root.join("spec/fixtures/files/cover.png")),
      filename: "cover.png",
      content_type: "image/png"
    )
  end

  it "renders the title once when there is no cover photo" do
    visit unit_event_path(@unit, @event)

    expect(page).to have_css("h1", text: "Troop Meeting", count: 1)
  end

  context "with a cover photo" do
    before { attach_cover_photo }

    it "renders the title once, inside the cover photo" do
      visit unit_event_path(@unit, @event)

      expect(page).to have_css("h1", text: "Troop Meeting", count: 1)
      expect(page).to have_css("h1.text-white", text: "Troop Meeting")
    end

    it "places the cover photo above the date block" do
      visit unit_event_path(@unit, @event)

      order = find("header.py-3").all("img, ol").map(&:tag_name)

      expect(order.first).to eq("img")
      expect(order).to include("ol")
    end
  end
end
