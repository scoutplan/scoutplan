# frozen_string_literal: true

require "rails_helper"
require "action_controller"

RSpec.describe DigestTexter, type: :model do
  describe "BaseTexter" do
    it "can't instantitate" do
      expect { ApplicationTexter.new }.to raise_error(RuntimeError)
    end
  end

  describe "DigestTexter" do
    it "can instantiate" do
      member = FactoryBot.build(:member)
      expect(DigestTexter.new(member)).to be_a(DigestTexter)
    end

    it "renders digest from template" do
      User.destroy_all
      member = FactoryBot.create(:unit_membership)
      FactoryBot.create(:event, unit: member.unit)
      texter = DigestTexter.new(member)
      body = texter.body
      expect(body).to be_a(String)
    end

    it "sends" do
      User.destroy_all
      member = FactoryBot.create(:unit_membership)
      FactoryBot.create(:event, unit: member.unit)
      texter = DigestTexter.new(member)
      expect{ texter.send_message }.not_to raise_exception
    end
  end
end
