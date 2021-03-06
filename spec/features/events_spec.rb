# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "events", type: :feature do
  before do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit  = FactoryBot.create(:unit)
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

    @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
    @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)
  end

  describe "public page" do
    it "is accessible when logged out" do
      path = public_unit_events_path(@unit)
      logout(:user)
      visit(path)
      expect(page).to have_current_path(path)
    end
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
        visit(path = unit_event_path(@unit, @event))
        expect(page).to have_current_path(path)
      end

      it "does not display a Publish button on published events" do
        event = FactoryBot.create(:event, :published, unit: @unit, title: "Published event")
        visit unit_event_path(@unit, event)
        expect(page).not_to have_selector(:link_or_button, "Publish")
      end

      it "does not display Cancel link on cancelled events" do
        @event.update!(status: :cancelled)
        visit edit_unit_event_path(@unit, @event)
        expect(page).not_to have_link(I18n.t("events.show.cancel_title"))
      end
    end

    describe "update" do
      it "updates an event" do
        visit edit_unit_event_path(@unit, @event)
        expect(page).to have_current_path(edit_unit_event_path(@unit, @event))

        fill_in :event_title, with: "New Event Title"
        click_button "Save Changes"

        @event.reload
        expect(page).to have_current_path(unit_event_path(@unit, @event))
      end
    end
  end

  describe "as a non-admin" do
    before :each do
      login_as(@normal_user, scope: :user)
    end

    it "prevents access a draft Event page" do
      path = unit_event_path(@unit, @event)
      expect { visit path }.to raise_error Pundit::NotAuthorizedError
    end

    it "prevents access to the Organize page" do
      expect { visit unit_event_rsvps_path(@unit, @event) }.to raise_error Pundit::NotAuthorizedError
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

  describe "variations" do
    before :each do
      login_as(@normal_user, scope: :user)
    end

    it "shows as a calendar" do
      path = calendar_unit_events_path(@unit)
      visit(path)
      expect(page).to have_current_path(path)
    end
  end

  describe "planner" do
    before :each do
      login_as(@normal_user, scope: :user)
    end

    it "visits the page" do
      path = unit_plans_path(@unit)
      visit(path)
      expect(page).to have_current_path(path)
    end
  end
end
# rubocop:enable Metrics/BlockLength
