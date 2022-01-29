# frozen_string_literal: true

require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "events", type: :feature do
  before do
    @unit = FactoryBot.create(:unit_with_members)
    @event = FactoryBot.create(:event, unit: @unit)
    @member = FactoryBot.create(:member, :admin, unit: @unit)
    login_as(@member.user, scope: :user)
  end

  it "navigates to the organize page" do
    visit(unit_event_organize_path(@unit, @event))
    expect(page).to have_current_path(unit_event_organize_path(@unit, @event))
  end

  it "prevents non-admin from accessing the organize page" do
    login_as(@unit.members.first.user, scope: :user)
    expect { visit(unit_event_organize_path(@unit, @event)) }.to raise_error Pundit::NotAuthorizedError
  end

  it "contains all members without dupes" do
    visit(unit_event_organize_path(@unit, @event))
    @unit.members.each do |member|
      expect(page).to have_content(member.full_display_name, count: 1)
    end
  end

  describe "accepted RSVPs" do
    before do
      @other_member = @unit.members.first
      @rsvp = @event.rsvps.create(unit_membership: @other_member, response: :accepted, respondent: @member)
      visit(unit_event_organize_path(@unit, @event))
    end

    it "displays accepted members in the 'Going' section" do
      rsvp_list = find(:css, "#accepted_rsvp_container")
      expect(rsvp_list).to have_text(@other_member.full_display_name)
    end

    it "changes RSVP to 'not going' by clicking on the 'Change RSVP' button" do
      change_rsvp_button = find_button("change_rsvp_#{@rsvp.id}_button")
      expect(change_rsvp_button).to have_text(I18n.t("events.organize.actions.decline"))
      change_rsvp_button.click

      rsvp_list = find(:css, "#declined_rsvp_container")
      expect(rsvp_list).to have_text(@other_member.full_display_name)
    end
  end

  describe "declined RSVPs" do
    before do
      @other_member = @unit.members.first
      @rsvp = @event.rsvps.create(unit_membership: @other_member, response: :declined, respondent: @member)
      visit(unit_event_organize_path(@unit, @event))
    end

    it "displays accepted members in the 'Not Going' section" do
      rsvp_list = find(:css, "#declined_rsvp_container")
      expect(rsvp_list).to have_text(@other_member.full_display_name)
    end

    it "changes RSVP to 'going' by clicking on the 'Change RSVP' button" do
      change_rsvp_button = find_button("change_rsvp_#{@rsvp.id}_button")
      expect(change_rsvp_button).to have_text(I18n.t("events.organize.actions.accept"))
      change_rsvp_button.click

      rsvp_list = find(:css, "#accepted_rsvp_container")
      expect(rsvp_list).to have_text(@other_member.full_display_name)
    end
  end
end
# rubocop:enable Metrics/BlockLength
