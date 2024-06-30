require "rails_helper"
require "sidekiq/testing"

RSpec.describe WeeklyDigestNotifier do
  include ActiveJob::TestHelper
  include ActiveSupport::Testing::TaggedLogging

  let(:name) { "RsvpLastCallNotifier" }

  before do
    @event = FactoryBot.create(:event)
    @unit = @event.unit
    @member = FactoryBot.create(:unit_membership, :adult, unit: @unit)
    @unit.unit_memberships.each do |member|
      member.user.update(phone: "+15005550006")
    end
  end

  it "creates a notifier" do
    expect(WeeklyDigestNotifier.new).to be_a(ScoutplanNotifier)
  end

  describe "Twilio" do
    it "renders the SMS body" do
      notifier = WeeklyDigestNotifier.with(unit: @unit)
      body = notifier.sms_body(recipient: @member, unit: @unit)
      expect(body).to include("There's nothing on the docket")
      puts body

      FactoryBot.create(:event, unit: @unit, starts_at: Time.zone.now + 1.day, ends_at: Time.zone.now + 2.days, status: "published")
      body = notifier.sms_body(recipient: @member, unit: @unit)
      expect(body).not_to include("There's nothing on the docket")
      expect(body).to include(@event.title)
      puts body
    end
  end

  it "delivers an email" do
    # skip "This test works standalone, but not in the suite. It's a known issue."
    Flipper.enable(:deliver_email)

    clear_enqueued_jobs

    # Sidekiq::Testing.inline!
    Sidekiq::Testing.fake!
    expect { WeeklyDigestNotifier.with(unit: @unit).deliver(@unit.unit_memberships.first) }.to have_enqueued_job(Noticed::EventJob)

    perform_enqueued_jobs
    expect(ActiveJob::Base.queue_adapter.enqueued_jobs.count).to be > 0
    perform_enqueued_jobs
    expect(ActionMailer::Base.deliveries.count).to eq(1)
  end
end
