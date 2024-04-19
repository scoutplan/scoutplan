require "rails_helper"

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

  describe "index page" do
    before do
      login_as(@admin_user, scope: :user)
      path = unit_events_path(@unit)
      visit(path)
    end

    describe "headcount-limited events" do
      before do
        @event = FactoryBot.create(:event, :published, :requires_rsvp, :limit_headcount, unit: @unit, title: "Headcount Event")
      end

      # it "shows the headcount on the index page" do
      #   visit unit_events_path(@unit)
      #   expect(page).to have_content("10 spots left")
      # end

      it "shows RSVP closed when the event is full" do
        10.times do
          member = FactoryBot.create(:unit_membership, unit: @unit, status: :active)
          @event.rsvps.create!(member: member, response: "accepted", respondent: member)
        end

        visit unit_events_path(@unit)
        expect(page).to have_content("RSVPs are closed")
      end
    end
  end
end
