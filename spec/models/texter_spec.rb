# frozen_string_literal: true

require "rails_helper"
require "action_controller"

def render_text_body_to_console(body)
  puts
  puts "*********************************"
  puts body
  puts "*********************************"
  puts
end

# rubocop:disable Metrics/BlockLength
RSpec.describe DigestTexter, type: :model do
  describe "ApplicationTexter" do
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
      render_text_body_to_console(body)
      expect(body).to be_a(String)
    end

    it "sends" do
      User.destroy_all
      member = FactoryBot.create(:unit_membership)
      FactoryBot.create(:event, unit: member.unit)
      texter = DigestTexter.new(member)
      expect { texter.send_message }.not_to raise_exception
    end
  end

  describe "DailyReminderTexter" do
    it "can instantiate" do
      member = FactoryBot.build(:member)
      expect(DailyReminderTexter.new(member)).to be_a(DailyReminderTexter)
    end

    it "renders reminders from template" do
      User.destroy_all
      member = FactoryBot.create(:unit_membership)
      FactoryBot.create(:event, :published, unit: member.unit, starts_at: 8.hours.from_now)
      texter = DailyReminderTexter.new(member)
      body = texter.body
      render_text_body_to_console(body)
      expect(body).to be_a(String)
    end
  end
end
# rubocop:enable Metrics/BlockLength
