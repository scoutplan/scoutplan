# frozen_string_literal: true

require "rails_helper"

describe "weekly digest note", type: :request do
  let(:unit) { FactoryBot.create(:unit) }
  let(:admin) { FactoryBot.create(:member, :admin, unit: unit) }
  let(:plain_member) { FactoryBot.create(:member, unit: unit) }

  describe "PATCH /u/:unit (settings form)" do
    it "saves the note and the keep setting" do
      login_as(admin.user, scope: :user)

      patch "/u/#{unit.to_param}", params: {
        unit:     { digest_note: "<div>Bring canned food Monday</div>" },
        settings: { communication: { digest_note_keep: "true" } }
      }

      unit.reload
      expect(unit.digest_note.to_plain_text).to include("Bring canned food Monday")
      expect(unit.keep_digest_note?).to be(true)
    end
  end

  describe "GET /u/:unit/settings/digest_preview" do
    before { unit.update!(digest_note: "<div>Bring canned food Monday</div>") }

    it "shows an admin the digest with the note" do
      login_as(admin.user, scope: :user)

      get "/u/#{unit.to_param}/settings/digest_preview"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Bring canned food Monday")
    end

    it "refuses a plain member" do
      login_as(plain_member.user, scope: :user)

      get "/u/#{unit.to_param}/settings/digest_preview"

      expect(response.body).not_to include("Bring canned food Monday")
    end
  end

  describe "POST test send" do
    it "refuses a plain member" do
      login_as(plain_member.user, scope: :user)

      expect do
        post "/u/#{unit.to_param}/members/#{admin.id}/test_communications", params: { message_type: "digest" }
      end.not_to(change { Noticed::Event.count })
    end
  end
end
