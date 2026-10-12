# frozen_string_literal: true

require "rails_helper"

describe "inactive member lockout", type: :request do
  let(:unit) { FactoryBot.create(:unit) }

  describe "GET /u/:unit/schedule" do
    it "lets an active member in" do
      member = FactoryBot.create(:member, unit: unit)
      login_as(member.user, scope: :user)

      get unit_events_path(unit)
      follow_redirect!

      expect(response).to have_http_status(:ok)
    end

    it "lets a registered member in" do
      member = FactoryBot.create(:member, :registered, unit: unit)
      login_as(member.user, scope: :user)

      get unit_events_path(unit)
      follow_redirect!

      expect(response).to have_http_status(:ok)
    end

    it "turns an inactive member away" do
      member = FactoryBot.create(:member, :inactive, unit: unit)
      login_as(member.user, scope: :user)

      get unit_events_path(unit)

      expect(response).to redirect_to(root_path)
    end

    it "turns an inactive admin away" do
      member = FactoryBot.create(:member, :inactive, :admin, unit: unit)
      login_as(member.user, scope: :user)

      get unit_events_path(unit)

      expect(response).to redirect_to(root_path)
    end
  end

  describe "GET /" do
    it "signs out a member with no active membership" do
      member = FactoryBot.create(:member, :inactive, unit: unit)
      login_as(member.user, scope: :user)

      get root_path

      expect(response).to redirect_to(new_user_session_path)
      expect(flash[:alert]).to eq("You don't have an active membership.")

      get unit_events_path(unit)

      expect(response).to redirect_to(new_user_session_path)
    end

    it "sends a member to the unit where they are still active" do
      user = FactoryBot.create(:user)
      FactoryBot.create(:member, :inactive, unit: unit, user: user)
      active_membership = FactoryBot.create(:member, user: user)
      login_as(user, scope: :user)

      get root_path

      expect(response).to redirect_to(unit_events_path(active_membership.unit))
    end
  end
end
