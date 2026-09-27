# frozen_string_literal: true

require "rails_helper"

describe "creating a unit membership", type: :request do
  let(:unit) { FactoryBot.create(:unit) }
  let(:admin) { FactoryBot.create(:member, :admin, unit: unit) }
  let(:plain_member) { FactoryBot.create(:member, unit: unit) }

  def create_member(email:, role: "member", first_name: "Pat", last_name: "Parent")
    post "/u/#{unit.to_param}/members", params: {
      unit_membership: {
        role: role, status: "active", member_type: "adult",
        user_attributes: {first_name: first_name, last_name: last_name, email: email}
      }
    }
  end

  describe "authorization" do
    it "lets an admin add a member" do
      login_as(admin.user, scope: :user)

      expect { create_member(email: "new@example.com") }.to change { unit.memberships.count }.by(1)
    end

    # create had no authorize call at all, and member_params permits :role, so
    # any signed-in member could mint themselves an admin account
    it "refuses a plain member" do
      login_as(plain_member.user, scope: :user)

      expect { create_member(email: "mallory@example.com", role: "admin") }
        .not_to change { unit.memberships.count }
    end
  end

  describe "when the address already belongs to a member" do
    before do
      @existing = FactoryBot.create(:member, unit: unit)
      @existing.user.update!(email: "shared@example.com")
      login_as(admin.user, scope: :user)
    end

    it "does not raise, and does not create anything" do
      expect { create_member(email: "shared@example.com") }
        .not_to change { unit.memberships.count }
    end

    it "answers 422 rather than a 500" do
      create_member(email: "shared@example.com")

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "says which address is the problem" do
      create_member(email: "shared@example.com")

      expect(response.body).to include("shared@example.com")
      expect(response.body).to include("already belongs to a member of this unit")
    end
  end

  # distinct from the duplicate-email path, which is caught before save: this is
  # a genuine validation failure reaching save, which used to raise from save!
  describe "when the submitted details are invalid" do
    before { login_as(admin.user, scope: :user) }

    it "re-renders instead of raising" do
      expect { create_member(email: "blank@example.com", last_name: "") }
        .not_to change { unit.memberships.count }

      expect(response).to have_http_status(:unprocessable_entity)
    end

    it "shows the reason on the form" do
      create_member(email: "blank@example.com", last_name: "")

      # parsed, not string-matched: the apostrophe is HTML-escaped in the source
      text = Nokogiri::HTML(response.body).text

      expect(text).to include("can't be blank")
    end
  end

  describe "an address belonging to a user outside this unit" do
    it "reuses the existing user rather than colliding on the unique email" do
      outsider = FactoryBot.create(:member)
      outsider.user.update!(email: "moved@example.com")
      login_as(admin.user, scope: :user)

      expect { create_member(email: "moved@example.com") }
        .to change { unit.memberships.count }.by(1)
        .and change { User.count }.by(0)
    end
  end

  describe "GET email_availability" do
    before { login_as(admin.user, scope: :user) }

    it "reports a free address as available" do
      get "/u/#{unit.to_param}/members/email_availability", params: {email: "free@example.com"}

      expect(response.parsed_body["available"]).to be(true)
      expect(response.parsed_body["message"]).to be_nil
    end

    it "reports a taken address with a message" do
      taken = FactoryBot.create(:member, unit: unit)
      taken.user.update!(email: "taken@example.com")

      get "/u/#{unit.to_param}/members/email_availability", params: {email: "taken@example.com"}

      expect(response.parsed_body["available"]).to be(false)
      expect(response.parsed_body["message"]).to include("taken@example.com")
    end

    it "is not readable by a plain member" do
      login_as(plain_member.user, scope: :user)

      get "/u/#{unit.to_param}/members/email_availability", params: {email: "taken@example.com"}

      expect(response).to have_http_status(:redirect)
    end
  end
end
