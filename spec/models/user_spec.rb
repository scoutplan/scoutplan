# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.create(:user)).to be_valid
  end

  describe 'methods' do
    it 'identifies anonymous email addresses' do
      email = 'anonymous-member-3bfa32609c1b@scoutplan.org'
      user = FactoryBot.build(:user, email: email)
      expect(user.anonymous_email?).to be_truthy
    end

    it 'generates an anonymous email if needed' do
      user = FactoryBot.build(:user, email: nil)
      user.save!
      expect(user.email).to be_present
      expect(user.anonymous_email?).to be_truthy
    end

    describe "disable_delivery" do
      before do
        @member = FactoryBot.create(:unit_membership)
        @user = @member.user
      end

      it "disables email" do
        expect(@member.settings(:communication).via_email).to be_truthy
        @user.disable_delivery!(method: :email)
        @member.reload
        expect(@member.settings(:communication).via_email).to be_falsey
      end
    end
  end
end
