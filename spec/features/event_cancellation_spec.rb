# frozen_string_literal: true

require "rails_helper"
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
      expect(event.reload).to be_cancelled
    end

    it "notifies active members and keeps the event listed for them" do
      event = FactoryBot.create(:event, :published, unit: @unit, title: "Graymoor")
      visit unit_event_cancel_path(@unit, event)
      choose :event_cancellation_message_audience_active_members
      fill_in "event_cancellation_message", with: "Rained out"
      expect { click_link_or_button I18n.t("events.cancel.proceed") }
        .to change { EventCancellationNotifier.count }.by(1)
      expect(event.reload).to be_cancelled
      expect(EventCancellationNotifier.last.params[:note]).to eq("Rained out")

      login_as(@normal_member.user)
      visit list_unit_events_path(@unit)
      expect(page).to have_content("Graymoor")
    end

    it "marks the event as cancelled on the list, the calendar and the event page" do
      event = FactoryBot.create(:event, :published, unit: @unit, title: "Graymoor")
      visit unit_event_cancel_path(@unit, event)
      click_link_or_button I18n.t("events.cancel.proceed")

      login_as(@normal_member.user)
      visit list_unit_events_path(@unit)
      within("##{ActionView::RecordIdentifier.dom_id(event)}") do
        expect(page).to have_css(".line-through", text: "Graymoor")
        expect(page).to have_content(I18n.t("events.index.cancelled"))
      end

      visit calendar_unit_events_path(@unit, year: event.starts_at.year, month: event.starts_at.month)
      expect(page).to have_css(".event-cancelled.line-through", text: "Graymoor")

      visit unit_event_path(@unit, event)
      expect(page).to have_content(I18n.t("events.show.cancelled_banner"))
    end

    it "does not let a non-admin cancel an event" do
      login_as(@normal_member.user)
      page.driver.submit :post, unit_event_cancellations_path(@unit, @event), {}
      expect(@event.reload).to be_published
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
        perform_enqueued_jobs
      end

      it "does not notify when none is selected" do
        choose :event_cancellation_message_audience_none
        click_link_or_button I18n.t("events.cancel.proceed")
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
