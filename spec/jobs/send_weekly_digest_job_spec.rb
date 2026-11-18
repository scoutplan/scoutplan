require "rails_helper"
require "active_job/test_helper"

RSpec.describe SendWeeklyDigestJob, type: :job do
  include ActiveJob::TestHelper

  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @unit.settings(:communication).digest = "true"
    @unit.save!
  end

  it "executes successfully" do
    ActiveJob::Base.queue_adapter = :test
    expect { SendWeeklyDigestJob.perform_later(@unit.id) }.to have_enqueued_job
    perform_enqueued_jobs
  end

  it "performs" do
    @unit.settings(:communication).digest = "true"
    @unit.save!
    expect { SendWeeklyDigestJob.perform_now(@unit.id) }.not_to raise_error
  end

  describe "digest note" do
    before do
      @unit.update!(digest_note: "<div>Popcorn orders due Friday</div>")
    end

    it "passes the note to the notifier" do
      expect(WeeklyDigestNotifier).to receive(:with)
        .with(hash_including(unit: @unit, digest_note_html: a_string_including("Popcorn orders due Friday")))
        .and_call_original
      SendWeeklyDigestJob.perform_now(@unit.id)
    end

    it "clears the note after sending" do
      SendWeeklyDigestJob.perform_now(@unit.id)
      expect(@unit.reload.digest_note).to be_blank
    end

    it "keeps the note when the unit asks to" do
      @unit.settings(:communication).update!(digest_note_keep: "true")
      SendWeeklyDigestJob.perform_now(@unit.id)
      expect(@unit.reload.digest_note.to_plain_text).to include("Popcorn orders due Friday")
    end

    it "keeps the note when the digest didn't send" do
      @unit.settings(:communication).update!(digest_last_ran_at: 1.hour.ago.iso8601)
      SendWeeklyDigestJob.perform_now(@unit.id)
      expect(@unit.reload.digest_note.to_plain_text).to include("Popcorn orders due Friday")
    end
  end

  describe "Unit#clear_digest_note!" do
    it "leaves a note that was edited after the send started" do
      @unit.update!(digest_note: "<div>Old note</div>")
      sent_version = @unit.rich_text_digest_note.updated_at
      @unit.rich_text_digest_note.update!(body: "<div>New note</div>", updated_at: sent_version + 1.second)

      @unit.clear_digest_note!(sent_version: sent_version)

      expect(@unit.reload.digest_note.to_plain_text).to include("New note")
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
