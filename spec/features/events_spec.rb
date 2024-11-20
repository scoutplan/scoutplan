# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "events", type: :feature do
  before do
    User.where(email: "test_admin@scoutplan.org").destroy_all
    User.where(email: "test_normal@scoutplan.org").destroy_all

    @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
    @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

    @unit = FactoryBot.create(:unit)
    @draft_event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")
    @published_event = FactoryBot.create(:event, :published, unit: @unit, title: "Published Event")

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

  describe "public access" do
    it "isn't accessible when policy unset" do
      logout(:user)
      path = unit_events_path(@unit)
      visit(path)
      expect(page).not_to have_current_path(path)
    end

    it "is accessible when policy set" do
      logout(:user)
      @unit.update!(public_calendar: true)
      path = list_unit_events_path(@unit)
      visit(path)
      expect(page).to have_current_path(path)
    end

    it "denies access to an event" do
      @unit.update!(public_calendar: true)
      path = unit_event_path(@unit, @published_event)
      visit(path)
      expect(page).not_to have_current_path(path)
    end
  end

  describe "events index" do
    before do
      login_as(@admin_user, scope: :user)
      path = unit_events_path(@unit)
      visit(path)
    end

    it "shows in-flight events" do
      event_title = "In-Flight Event"
      FactoryBot.create(:event,
                        status: :published, unit: @unit, starts_at: 2.days.ago,
                        ends_at: 1.day.from_now, title: event_title)
      visit current_path # reload the page
      expect(page).to have_content(event_title)
    end

    it "shows events from earlier today" do
      logout(:user)
      login_as(@normal_user, scope: :user)
      Time.zone = "America/New_York"
      FactoryBot.create(:event,
                        :published,
                        title:     "Earlier today",
                        unit:      @unit,
                        starts_at: DateTime.current.change(hour: 19, min: 0),
                        ends_at:   DateTime.current.change(hour: 20, min: 30))
      t = DateTime.current.change(hour: 20, min: 0)
      Timecop.freeze(t)
      visit unit_events_path(@unit)
      expect(page).to have_content("Earlier today")
    end
  end

  describe "as an admin..." do
    before :each do
      login_as(@admin_user, scope: :user)
    end

    describe "index" do
      it "displays the Add Event button on the Index page" do
        skip "no longer applicable"

        login_as(@admin_user)
        visit list_unit_events_path(@unit)
        expect(page).to have_selector(:link_or_button, "Add an Event")
        logout
      end

      it "shows draft events on the Index page" do
        skip "no longer applicable"

        visit unit_events_path(@unit)
        expect(page).to have_content("Draft Event")
      end

      describe "organize buttons" do
        before do
          @organizable_event = FactoryBot.create(:event, :requires_rsvp, unit: @unit)
        end

        it "navigates to event organize page", js: true do
          skip
          page.driver.browser.js_errors = false

          visit unit_events_path(@unit)
          link_id = "#organize_event_#{@organizable_event.id}_link"
          link = page.find(link_id)
          link.click
          expect(page).to have_current_path(unit_event_organize_path(@unit, @organizable_event))
        end
      end
    end

    describe "list" do
      it "hides drafts for non-admins" do
        login_as(@normal_member.user, scope: :user)

        visit list_unit_events_path(@unit)
        expect(page).to have_content(@published_event.title)
        expect(page).not_to have_content(@draft_event.title)
      end

      it "shows drafts for admins" do
        skip "no longer applicable"

        visit list_unit_events_path(@unit)
        expect(page).to have_content(@published_event.title)
        expect(page).to have_content(@draft_event.title)
      end
    end

    describe "show" do
      it "accesses drafts" do
        skip "no longer applicable"

        visit(path = unit_event_path(@unit, @draft_event))
        expect(page).to have_current_path(path)
      end

      it "shows an Event with a location" do
        skip "no longer applicable"

        location = FactoryBot.create(:location, unit: @unit)
        @draft_event.event_locations.create(location: location, location_type: :arrival)
        path = unit_event_path(@unit, @draft_event)
        visit(path)
        expect(page).to have_current_path(path)
      end

      it "shows an event without only a departure location" do
        skip "no longer applicable"
        location = FactoryBot.create(:location, unit: @unit)
        @draft_event.event_locations.destroy_all
        @draft_event.event_locations.create!(location: location, location_type: :departure)

        path = unit_event_path(@unit, @draft_event)
        visit(path)
        expect(page).to have_current_path(path)
      end

      # it "does not display a Publish button on published events" do
      #   event = FactoryBot.create(:event, :published, unit: @unit, title: "Published event")
      #   visit unit_event_path(@unit, event)
      #   expect(page).not_to have_selector(:link_or_button, "Publish")
      # end

      it "does not display Cancel link on cancelled events" do
        skip

        @draft_event.update!(status: :cancelled)
        visit edit_unit_event_path(@unit, @draft_event)
        expect(page).not_to have_link(I18n.t("events.show.cancel_title"))
      end

      it "hides times for all-day events" do
        skip "no longer applicable"

        path = unit_event_path(@unit, @draft_event)
        visit(path)
        expect(page).to have_content(@draft_event.starts_at.strftime("%-I:%M"))
        @draft_event.update!(all_day: true)
        visit(path)
        expect(page).not_to have_content(@draft_event.starts_at.strftime("%-I:%M"))
      end

      it "returns to the previous view" do
        skip
        event2 = FactoryBot.create(:event, :published, unit: @unit, starts_at: 1.month.from_now,
ends_at: 1.month.from_now + 1.hour)
        path = calendar_unit_events_path(@unit, year: 1.month.from_now.year, month: 1.month.from_now.month)
        visit(path)

        click_link(event2.title)
        click_link("Event schedule")
        expect(page).to have_current_path(path)
      end
    end

    describe "update" do
      it "updates an event" do
        skip "no longer applicable"

        visit edit_unit_event_path(@unit, @draft_event)
        expect(page).to have_current_path(edit_unit_event_path(@unit, @draft_event))

        fill_in :event_title, with: "New Event Title"
        click_button "Save Changes"

        @draft_event.reload
        expect(page).to have_current_path(unit_event_path(@unit, @draft_event))
      end

      it "strips whitespace" do
        skip "no longer applicable"

        visit edit_unit_event_path(@unit, @draft_event)
        check "This is an online event", allow_label_click: true
        fill_in :event_website, with: " http://www.example.com "
        click_button "Save Changes"

        @draft_event.reload
        expect(@draft_event.website).to eq("http://www.example.com")
      end

      it "updates all day" do
        skip
        visit edit_unit_event_path(@unit, @draft_event)

        find(css: "#event_all_day").click

        # check "#event_all_day", allow_label_click: true
        click_button "Save Changes"

        @draft_event.reload
        expect(@draft_event.all_day).to be_truthy
      end
    end
  end

  describe "as an event organizer" do
    it "can access the event page page" do
      login_as(@normal_member.user, scope: :user)

      expect do
        @draft_event.event_organizers.create!(unit_membership: @normal_member, assigned_by: @admin_member)
      end.to change {
               @draft_event.organizers.count
             }.by(1)
      expect(@draft_event.organizer?(@normal_member)).to be_truthy
      visit unit_event_path(@unit, @draft_event)
      expect(page).to have_current_path(unit_event_path(@unit, @draft_event))
    end
  end

  describe "as a non-admin" do
    before :each do
      login_as(@normal_user, scope: :user)
    end

    it "prevents access a draft Event page" do
      path = unit_event_path(@unit, @draft_event)
      visit path
      expect(page).to have_current_path(list_unit_events_path(@unit))
    end

    it "hides the add event button on the Index page" do
      login_as(@normal_user, scope: :user)
      visit unit_events_path(@unit)
      expect(page).not_to have_selector(:link_or_button, I18n.t("events.index.new_button_caption"))
      logout
    end

    it "hides draft events on the Index page" do
      visit unit_events_path(@unit)
      expect(page).not_to have_content("Draft Event")
    end

    it "prevents non-admins from accessing" do
      event = FactoryBot.create(:event, :published, :past, unit: @unit)
      visit edit_unit_event_path(event.unit, event)
      expect(page).to have_current_path(list_unit_events_path(@unit))
    end
  end

  describe "calendar" do
    before :each do
      login_as(@normal_user, scope: :user)
    end

    it "shows calendar" do
      path = calendar_unit_events_path(@unit, year: Date.today.year, month: Date.today.month)
      visit(path)
      expect(page).to have_current_path(path)
    end

    it "works across multiple months" do
      event1 = FactoryBot.create(:event, :published, unit: @unit, starts_at: 1.hour.from_now, ends_at: 2.hours.from_now)
      puts event1.inspect
      event2 = FactoryBot.create(:event, :published, unit: @unit, starts_at: 1.month.from_now,
ends_at: 1.month.from_now + 1.hour)
      path = calendar_unit_events_path(@unit, year: Date.today.year, month: Date.today.month)

      visit(path)
      expect(page).to have_content(event1.title)

      path = calendar_unit_events_path(@unit, year: 1.month.from_now.year, month: 1.month.from_now.month)
      visit(path)
      expect(page).to have_content(event2.title)
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
