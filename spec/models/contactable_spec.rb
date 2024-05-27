require "rails_helper"

RSpec.describe Contactable, type: :model do
  it "is contactable" do
    member = FactoryBot.create(:unit_membership)
    expect(member.contactable?(via: :sms)).to be_falsey
    expect(member.contactable?(via: :email)).to be_truthy
    expect(member.contactable?).to be_truthy

    member.settings(:communication).update!(via_sms: true)
    member.reload
    expect(member.contactable?(via: :sms)).to be_truthy

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
end
