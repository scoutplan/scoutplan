# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "events", type: :feature do
  before :each do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit  = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    @unit.memberships.create(user: @admin_user,  role: "admin", status: :active)
    @unit.memberships.create(user: @normal_user, role: "member", status: :active)
  end

  describe "as an admin..." do
    before :each do
      login_as(@admin_user, scope: :user)
    end

    describe "index" do
      it "displays the Add Event button on the Index page" do
        login_as(@admin_user)
        visit unit_events_path(@unit)
        expect(page).to have_selector(:link_or_button, I18n.t("event_add"))
        logout
      end

      it "shows draft events on the Index page" do
        visit unit_events_path(@unit)
        expect(page).to have_content("Draft Event")
      end
    end

    describe "show" do
      it "accesses drafts" do
        visit(path = event_path(@event))
        expect(page).to have_current_path(path)
      end

      it "does not display a Publish button on published events" do
        event = FactoryBot.create(:event, :published, unit: @unit, title: "Published event")
        visit event_path(event)
        expect(page).not_to have_selector(:link_or_button, "Publish")
      end
    end

    describe "cancel" do
      it "visits the cancel page" do
        event = FactoryBot.create(:event, :published, unit: @unit, title: "Published event")
        visit edit_unit_event_path(event.unit, event)
        expect(page).to have_selector(:link_or_button, I18n.t("events.show.cancel_title"))
        click_link_or_button I18n.t("events.show.cancel_title")
        expect(page).to have_current_path(unit_event_cancel_path(event.unit, event))
        expect(page).to have_selector(:link_or_button, I18n.t("events.cancel.proceed"))
        expect(page).to have_selector(:link_or_button, I18n.t("events.cancel.abandon"))
      end

      it "warns when event is past" do
        event = FactoryBot.create(:event, :published, :past, unit: @unit)
        visit unit_event_cancel_path(event.unit, event)
        expect(page).to have_content(I18n.t("events.cancel.past_warning"))
      end
    end

    describe "organize" do
      it "accesses the page" do
        path = organize_event_path(@event)
        visit path
        expect(page).to have_current_path(path)
      end
    end
  end

  describe "as a non-admin" do
    before :each do
      login_as(@normal_user, scope: :user)
    end

    it "prevents access a draft Event page" do
      path = event_path(@event)
      expect { visit path }.to raise_error Pundit::NotAuthorizedError
    end

    it "prevents access to the Organize page" do
      expect { visit organize_event_path(@event) }.to raise_error Pundit::NotAuthorizedError
    end

    it "hides the add event button on the Index page" do
      login_as(@normal_user, scope: :user)
      visit unit_events_path(@unit)
      expect(page).not_to have_selector(:link_or_button, I18n.t("event_add"))
      logout
    end

    it "hides draft events on the Index page" do
      visit unit_events_path(@unit)
      expect(page).not_to have_content("Draft Event")
    end

    it "prevents non-admins from accessing" do
      event = FactoryBot.create(:event, :published, :past, unit: @unit)
      expect { visit edit_unit_event_path(event.unit, event) }.to raise_error Pundit::NotAuthorizedError
    end
  end
end
# rubocop:enable Metrics/BlockLength