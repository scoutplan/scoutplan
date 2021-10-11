# frozen_string_literal: true

require 'rails_helper'

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
  end
end
