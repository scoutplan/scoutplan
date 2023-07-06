require "rails_helper"
require "action_mailbox/test_helper"
require "active_job/test_helper"

include ActionMailbox::TestHelper
include ActiveJob::TestHelper

RSpec.describe UnitOverflowMailbox, type: :mailbox do
  before do
    @unit = FactoryBot.create(:unit)
    3.times do
      FactoryBot.create(:member, unit: @unit, role: :admin, status: :active)
    end
  end

  subject do
    receive_inbound_email_from_mail(from: "snork@flupple.com",
                                    to: "#{@unit.slug}@devmail.scoutplan.org",
                                    subject: "Hello!")
  end

  it "delivers the email" do
    expect(subject.status).to eq("delivered")
  end

  it "enqueues a jobs for each admin" do
    expect do
      receive_inbound_email_from_mail(from: "snork@flupple.com",
                                      to: "#{@unit.slug}@devmail.scoutplan.org",
                                      subject: "Hello!")
    end.to change { enqueued_jobs.count }.by(@unit.members.admin.count + 1)
  end
end
