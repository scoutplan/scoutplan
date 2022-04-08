# frozen_string_literal: true

require "rails_helper"

describe "events", type: :request do
  # before do
  #   User.where(email: "test_admin@scoutplan.org").destroy_all
  #   User.where(email: "test_normal@scoutplan.org").destroy_all

  #   @admin_user  = FactoryBot.create(:user, email: "test_admin@scoutplan.org")
  #   @normal_user = FactoryBot.create(:user, email: "test_normal@scoutplan.org")

  #   @unit  = FactoryBot.create(:unit)
  #   @event = FactoryBot.create(:event, :draft, unit: @unit, title: "Draft Event")

  #   @admin_member = @unit.memberships.create(user: @admin_user, role: "admin", status: :active)
  #   @normal_member = @unit.memberships.create(user: @normal_user, role: "member", status: :active)
  # end

  # describe "pdf URL" do
  #   before do
  #     login_as(@admin_user, scope: :user)
  #   end

  #   it "generates a PDF" do
  #     path = unit_events_path(@unit, format: :pdf)
  #     puts path
  #     get path
  #     puts response.body
  #     expect(response.content_type).to include("application/pdf")
  #   end
  # end
end
