require "rails_helper"

RSpec.describe SendWeeklyDigestJob, type: :job do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @unit.settings(:communication).digest = "true"
    @unit.save!
  end

  # it "executes successfully" do
  #   ActiveJob::Base.queue_adapter = :test
  #   expect {
  #     SendWeeklyDigestJob.perform_later
  #   }.to have_enqueued_job
  # end

  # it "schedules the next job" do
  #   expect { SendWeeklyDigestJob.schedule_next_job(@unit) }.to have_enqueued_job
  # end

  # it "performs" do
  #   timestamp = DateTime.current
  #   @unit.settings(:communication).digest_config_timestamp = timestamp
  #   @unit.settings(:communication).digest = "true"
  #   @unit.save!
  #   expect { SendWeeklyDigestJob.perform_now(@unit.id, timestamp) }.not_to raise_error
  # end

  describe "WeeklyDigestNotification" do
    it "sends a notification" do
      expect {
        WeeklyDigestNotification.with(unit: @unit).deliver(@unit.members)
      }.to change { ActionMailer::Base.deliveries.count }.by(@unit.members.count)
    end
  end
end
