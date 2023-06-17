# frozen_string_literal: true

require "rails_helper"
require "sidekiq/testing"

# rubocop:disable Metrics/BlockLength
describe "event_cancellation", type: :feature do
  before :each do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit  = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)

    @event = FactoryBot.create(:event, :published, unit: @unit, title: "Published event")

    login_as(@admin_member.user)
  end

  describe "cancel" do
    it "visits the cancel page" do
      visit edit_unit_event_path(@unit, @event)

      expect(page).to have_selector(:link_or_button, I18n.t("events.show.cancel_title"))
      click_link_or_button I18n.t("events.show.cancel_title")
      expect(page).to have_current_path(unit_event_cancel_path(@unit, @event))
      expect(page).to have_selector(:link_or_button, I18n.t("events.cancel.proceed"))
      expect(page).to have_selector(:link_or_button, I18n.t("events.cancel.abandon"))
    end

    it "excludes acceptors option for events that do not have accepted RSVPs" do
      visit unit_event_cancel_path(@unit, @event)
      expect(page).not_to have_text("who plan on attending")
    end

    it "includes acceptors option for events that have accepted RSVPs" do
      @event.rsvps.create(member: @normal_member, respondent: @normal_member, response: :accepted)
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
      choose :event_message_audience_none
      expect { click_link_or_button "Cancel This Event" }.not_to raise_exception
    end

    describe "default selections" do
      it "defaults to 'none' when event is draft" do
        @event.update!(status: :draft)
        visit unit_event_cancel_path(@unit, @event)
        expect(page).to have_checked_field("event_message_audience_none")
      end

      it "defaults to 'active' when event is published" do
        visit unit_event_cancel_path(@unit, @event)
        expect(page).to have_checked_field("event_message_audience_active_members")
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
        choose :event_message_audience_none
        click_link_or_button "Cancel This Event"
      end

      it "sends to acceptors" do
        choose :event_message_audience_acceptors
        expect { click_link_or_button "Cancel This Event" }.to change { ActionMailer::Base.deliveries.count }.by(1)
      end

      it "sends to actives" do
        choose :event_message_audience_active_members
        expect { click_link_or_button "Cancel This Event" }.to change { ActionMailer::Base.deliveries.count }.by(2)
      end

      it "sends to everyone" do
        choose :event_message_audience_all_members
        expect { click_link_or_button "Cancel This Event" }.to change { ActionMailer::Base.deliveries.count }.by(3)
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
