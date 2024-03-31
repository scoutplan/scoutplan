require "rails_helper"
require "action_mailbox/test_helper"
require "active_job/test_helper"

RSpec.describe UnitOverflowMailbox, type: :mailbox do
  include ActiveJob::TestHelper
  include ActionMailbox::TestHelper

  before do
    @unit = FactoryBot.create(:unit)
    3.times do
      FactoryBot.create(:member, unit: @unit, role: :admin, status: :active)
    end

    @unit.unit_memberships.first.user.update(email: "snork@flupple.com")
  end

  subject do
    receive_inbound_email_from_mail(from:    "snork@flupple.com",
                                    to:      "#{@unit.slug}@devmail.scoutplan.org",
                                    subject: "Hello!",
                                    headers: { "Auto-Submitted" => "auto-replied" })
  end

  it "bounces the email" do
    expect(subject.status).to eq("delivered")
  end
end
