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

        # expect(page).to have_selector(:link_or_button, I18n.t("events.show.cancel_title"))
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

    describe "update" do
      it "updates an event" do
        visit edit_unit_event_path(@unit, @event)
        click_link_or_button I18n.t("global.save_changes")
        expect(page).to have_current_path(unit_event_path(@unit, @event))
      end
    end

    describe "organize" do
      before do
        @rsvp_event1 = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit, starts_at: 2.weeks.from_now.in_time_zone(@unit.settings(:locale).time_zone))
        @rsvp_event2 = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit, starts_at: 4.weeks.from_now.in_time_zone(@unit.settings(:locale).time_zone))
      end

      it "accesses the page" do
        path = organize_event_path(@rsvp_event1)
        visit path
        expect(page).to have_current_path(path)
      end

      it "next & previous link works" do
        visit unit_event_organize_path(@unit, @rsvp_event1)

        text = I18n.t("events.organize.next", title: @rsvp_event2.title, date: @rsvp_event2.starts_at.in_time_zone(@unit.settings(:locale).time_zone).strftime("%-d %b"))
        click_link_or_button(text)
        expect(page).to have_current_path(unit_event_organize_path(@unit, @rsvp_event2))

        text = I18n.t("events.organize.previous", title: @rsvp_event1.title, date: @rsvp_event1.starts_at.in_time_zone(@unit.settings(:locale).time_zone).strftime("%-d %b"))
        click_link_or_button(text)
        expect(page).to have_current_path(unit_event_organize_path(@unit, @rsvp_event1))
      end
    end

    describe "create" do
      it "creates a single event" do
        visit(new_unit_event_path(@unit))
        fill_in :event_title, with: "Event Title"
        fill_in :event_location, with: "Anytown, USA"
        fill_in :event_starts_at_date, with: 13.days.from_now
        fill_in :event_ends_at_date, with: 14.days.from_now
        select "Camping Trip", from: "event_event_category_id"
        expect{ click_link_or_button "Add This Event" }.to change { Event.count }.by(1)
      end

      it "creates a series" do
        visit(new_unit_event_path(@unit))
        fill_in :event_title, with: "Event Title"
        fill_in :event_location, with: "Anytown, USA"
        fill_in :event_starts_at_date, with: 13.days.from_now
        fill_in :event_ends_at_date, with: 14.days.from_now
        select "Camping Trip", from: "event_event_category_id"
        check :event_repeats
        fill_in :event_repeats_until, with: 10.weeks.from_now
        expect{ click_link_or_button "Add This Event" }.to change { Event.count }.by_at_least(4)
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

  require "icalendar"

  describe "ical" do
    it "works" do
      Time.zone = @unit.settings(:locale).time_zone
      starts_at = 36.hours.from_now
      ends_at = 38.hours.from_now
      event = FactoryBot.create( \
        :event,
        :published,
        unit: @unit,
        location: Faker::Address.community,
        description: Faker::Lorem.paragraph(sentence_count: 3),
        starts_at: starts_at,
        ends_at: ends_at \
      )
      magic_link = MagicLink.generate_link(@normal_member, "icalendar")
      visit(calendar_feed_unit_events_path(@unit, magic_link.token))

      cals = Icalendar::Calendar.parse(page.body)
      cal = cals.first
      cal_event = cal.events.first
      expect(cal_event.dtstart.utc).to be_within(1.second).of(starts_at)
      expect(cal_event.summary).to     eq(event.title)
      expect(cal_event.location).to    eq(event.location)
      expect(cal_event.description).to eq(event.description.to_plain_text)
    end
  end
end
# rubocop:enable Metrics/BlockLength
