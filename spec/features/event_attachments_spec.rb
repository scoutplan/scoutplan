# frozen_string_literal: true

require "rails_helper"

describe "event attachments", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :draft, unit: @unit)
    login_as(@member.user, scope: :user)
  end

  def attach_to(collection, filename)
    @event.public_send(collection).attach(
      io: StringIO.new("contents"), filename: filename, content_type: "text/plain"
    )
    @event.public_send(collection).find { |a| a.filename.to_s == filename }
  end

  describe "the edit form" do
    it "lists both visibility sets in a single list" do
      attach_to(:attachments, "everyone.txt")
      attach_to(:private_attachments, "organizers.txt")

      visit edit_unit_event_path(@unit, @event)

      within(".existing_attachments") do
        expect(page).to have_content("everyone.txt")
        expect(page).to have_content("organizers.txt")
      end
    end

    it "submits a public attachment under the public collection only" do
      attachment = attach_to(:attachments, "everyone.txt")

      visit edit_unit_event_path(@unit, @event)

      within("#attachment_#{attachment.id}") do
        expect(page).to have_css("input[name='event[attachments][]']:not([disabled])", visible: :all)
        expect(page).to have_css("input[name='event[private_attachments][]'][disabled]", visible: :all)
      end
    end

    it "submits a private attachment under the private collection only" do
      attachment = attach_to(:private_attachments, "organizers.txt")

      visit edit_unit_event_path(@unit, @event)

      within("#attachment_#{attachment.id}") do
        expect(page).to have_css("input[name='event[private_attachments][]']:not([disabled])", visible: :all)
        expect(page).to have_css("input[name='event[attachments][]'][disabled]", visible: :all)
      end
    end

    it "offers a single upload control rather than one per visibility set" do
      visit edit_unit_event_path(@unit, @event)

      expect(page).to have_button("Upload files", count: 1)
    end
  end
end
