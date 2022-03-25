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
    login_as(@admin_user, scope: :user)
  end

  describe "organize" do
    before do
      Time.zone = @unit.time_zone
      @rsvp_event1 = FactoryBot.create(
        :event,
        :published,
        :requires_rsvp,
        unit: @unit,
        starts_at: 14.days.from_now.in_time_zone,
        ends_at: 15.days.from_now.in_time_zone
      )
      @rsvp_event2 = FactoryBot.create(
        :event,
        :published,
        :requires_rsvp,
        unit: @unit,
        starts_at: 28.days.from_now.in_time_zone,
        ends_at: 29.days.from_now.in_time_zone
      )
    end

    it "prevents access to non-organizers" do
      login_as(@normal_user, scope: :user)
      path = unit_event_organize_path(@unit, @rsvp_event1)
      expect { visit path }.to raise_exception Pundit::NotAuthorizedError
    end

    it "accesses the page" do
      path = unit_event_organize_path(@unit, @rsvp_event1)
      visit path
      expect(page).to have_current_path(path)
    end

    it "next & previous link works" do
      visit unit_event_organize_path(@unit, @rsvp_event1)

      text = I18n.t("events.organize.next_short")
      click_link_or_button(text)
      expect(page).to have_current_path(unit_event_organize_path(@unit, @rsvp_event2))

      text = I18n.t("events.organize.previous_short")
      click_link_or_button(text)
      expect(page).to have_current_path(unit_event_organize_path(@unit, @rsvp_event1))
    end

    it "deletes declined RSVPs", js: true do
      @rsvp_event1.rsvps.create(unit_membership: @normal_member, response: :declined, respondent: @admin_member)
      visit unit_event_organize_path(@unit, @rsvp_event1)

      name_link = page.find("#unit_membership_#{@normal_member.id} > a")
      name_link.click

      delete_button = page.find("#unit_membership_#{@normal_member.id} .delete-rsvp-button")
      delete_button.click

      # this isn't really a good test. Needs improvement
    end

    it "deletes accepted RSVPs", js: true do
      @rsvp_event1.rsvps.create(unit_membership: @normal_member, response: :accepted, respondent: @admin_member)
      visit unit_event_organize_path(@unit, @rsvp_event1)

      name_link = page.find("#unit_membership_#{@normal_member.id} > a")
      name_link.click

      delete_button = page.find("#unit_membership_#{@normal_member.id} .delete-rsvp-button")
      delete_button.click

      # also not a good test
    end
  end
end
# rubocop:enable Metrics/BlockLength
