# frozen_string_literal: true

require "rails_helper"

RSpec.describe MemberNotifier, type: :model do
  before do
    User.destroy_all
    @member = FactoryBot.create(:member)
  end

  it "instantiates" do
    expect { MemberNotifier.new(@member) }.not_to raise_exception
  end

  describe "methods" do
    before do
      @notifier = MemberNotifier.new(@member)
    end

    it "sends a test message" do
      expect { @notifier.send_test_message }.not_to raise_exception
    end
  end
end
