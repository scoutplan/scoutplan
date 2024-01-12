require "rails_helper"

RSpec.describe EventRsvpConfirmationText, type: :model do
  it "instantiates" do
    expect(EventRsvpConfirmationText.new(FactoryBot.create(:event_rsvp), FactoryBot.create(:member))).to be_a(EventRsvpConfirmationText)
  end
end
