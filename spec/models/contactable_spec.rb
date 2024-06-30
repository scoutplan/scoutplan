require "rails_helper"

RSpec.describe Contactable, type: :model do
  it "is contactable" do
    member = FactoryBot.create(:unit_membership)
    expect(member.contactable?(via: :sms)).to be_truthy
    expect(member.contactable?(via: :email)).to be_truthy
    expect(member.contactable?).to be_truthy

    member.settings(:communication).update!(via_sms: false)
    member.reload
    expect(member.contactable?(via: :sms)).to be_falsey

    member.settings(:communication).update!(via_sms: true)
    member.settings(:communication).update!(via_email: false)
    member.reload
    expect(member.contactable?(via: :email)).to be_falsey
    expect(member.contactable?).to be_truthy

    member.settings(:communication).update!(via_sms: false)
    member.reload
    expect(member.contactable?(via: :sms)).to be_falsey
    expect(member.contactable?(via: :email)).to be_falsey
    expect(member.contactable?).to be_falsey
  end

  describe "contact_preference" do
    it "is false when value is false" do
      member = FactoryBot.create(:unit_membership)
      member.settings(:communication).via_sms = false
      expect(member.contact_preference?(via: :sms)).to be_falsey
    end

    it "is false when value is 'false'" do
      member = FactoryBot.create(:unit_membership)
      member.settings(:communication).via_sms = "false"
      expect(member.contact_preference?(via: :sms)).to be_falsey
    end
  end
end
