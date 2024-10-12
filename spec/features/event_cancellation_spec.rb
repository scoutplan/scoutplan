# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"
require "active_job/test_helper"

# rubocop:disable Metrics/BlockLength
describe "event_cancellation", type: :feature do
  include ActiveJob::TestHelper

  before :each do
    @admin_member = FactoryBot.create(:member, :admin)
    @unit = @admin_member.unit
    @normal_member = FactoryBot.create(:member, unit: @unit)
    @event = FactoryBot.create(:event, :published, unit: @unit, title: "Published event")
    login_as(@admin_member.user)
  end

  describe "cancel" do
    it "visits the cancel page" do
      visit edit_unit_event_path(@unit, @event)

      expect(page).to have_current_path(edit_unit_event_path(@unit, @event))
      expect(page).to have_content("Cancel this event")
      find(:id, "cancel_event_button").click
      expect(page).to have_current_path(unit_event_cancel_path(@unit, @event))
      expect(page).to have_selector(:link_or_button, I18n.t("events.cancel.proceed"))
    end

    it "excludes acceptors option for events that do not have accepted RSVPs" do
      visit unit_event_cancel_path(@unit, @event)
      expect(page).not_to have_text("who plan on attending")
    end

    it "includes acceptors option for events that have accepted RSVPs" do
      @event.rsvps.create!(member: @normal_member, respondent: @normal_member, response: :accepted)
      visit unit_event_cancel_path(@unit, @event)
      expect(page).to have_text("who plan on attending")
    end

    it "warns when event is past" do
      event = FactoryBot.create(:event, :published, :past, unit: @unit)
      visit unit_event_cancel_path(event.unit, event)
      expect(page).to have_content(I18n.t("events.cancel.past_warning"))
    end

    it "performs the cancellation" do
      event = FactoryBot.create(:event, :published, unit: @unit, title: "Published event")
      visit unit_event_cancel_path(@unit, event)
      choose :event_cancellation_message_audience_none
      expect { click_link_or_button I18n.t("events.cancel.proceed") }.not_to raise_exception
      expect(page).to have_current_path(list_unit_events_path(@unit))
    end

    describe "default selections" do
      it "defaults to 'none' when event is draft" do
        @event.update!(status: :draft)
        visit unit_event_cancel_path(@unit, @event)
        expect(page).to have_checked_field("event_cancellation_message_audience_none")
      end
    end

    describe "notifications" do
      before do
        FactoryBot.create(:unit_membership, :inactive, unit: @unit)
        FactoryBot.create(:unit_membership, :registered, unit: @unit)
        @event.rsvps.create(member: @normal_member, respondent: @normal_member, response: :accepted)
        visit unit_event_cancel_path(@unit, @event)
        Sidekiq::Testing.inline!
      end

      it "does not notify when none is selected" do
        choose :event_cancellation_message_audience_none
        click_link_or_button I18n.t("events.cancel.proceed")
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
