require "rails_helper"

RSpec.describe ComputeChildContactabilityJob, type: :job do
  include ActiveJob::TestHelper

  it "traps missing UnitMembership" do
    member = FactoryBot.create(:member)
    ComputeChildContactabilityJob.perform_later(member)
    member.destroy!
    perform_enqueued_jobs
  end
end
