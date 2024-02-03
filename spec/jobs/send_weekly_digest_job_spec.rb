require "rails_helper"

RSpec.describe SendWeeklyDigestJob, type: :job do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @unit.settings(:communication).digest = "true"
    @unit.save!
  end

  it "executes successfully" do
    ActiveJob::Base.queue_adapter = :test
    expect {
      SendWeeklyDigestJob.perform_later
    }.to have_enqueued_job
  end

  it "schedules the next job" do
    expect { SendWeeklyDigestJob.schedule_next_job(@unit) }.to have_enqueued_job
  end

  it "performs" do
    timestamp = DateTime.current
    @unit.settings(:communication).digest_config_timestamp = timestamp
    @unit.settings(:communication).digest = "true"
    @unit.save!
    expect { SendWeeklyDigestJob.perform_now(@unit.id, timestamp) }.not_to raise_error
  end

  describe "WeeklyDigestNotifier" do
    it "sends a notification" do
      expect { WeeklyDigestNotifier.with(unit: @unit).deliver(@unit.members) }.not_to raise_error
    end
  end

  describe "class methods" do
    describe "next_occurring" do
      it "returns the next occurrence when the day_of_week isn't today" do
        start_time = Date.current.next_occurring(:monday).change(hour: 8, min: 0, sec: 0)
        value = SendWeeklyDigestJob.next_occurring(start_time, :thursday, 0)
        expect(value).to eq(start_time.next_occurring(:thursday).change(hour: 8, min: 0, sec: 0))
      end

      it "returns today when the day_of_week is today and hour_of_day hasn't occurred yet" do
        start_time = DateTime.current.next_occurring(:monday).change(hour: 8, min: 0, sec: 0)
        value = SendWeeklyDigestJob.next_occurring(start_time, :monday, 9)
        expect(value).to eq(start_time.change(hour: 9, min: 0, sec: 0))
      end

      it "returns next week when the day_of_week is today and hour_of_day has already occurred" do
        start_time = DateTime.current.next_occurring(:monday).change(hour: 8, min: 0, sec: 0)
        value = SendWeeklyDigestJob.next_occurring(start_time, :monday, 7)
        expect(value).to eq(start_time.next_occurring(:monday).change(hour: 7, min: 0, sec: 0))
      end
    end
  end
end
