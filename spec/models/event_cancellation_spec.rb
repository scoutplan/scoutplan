# frozen_string_literal: true

require "rails_helper"

RSpec.describe EventCancellation do
  let(:unit) { FactoryBot.create(:unit) }
  let(:event) { FactoryBot.create(:event, :published, unit: unit, title: "Graymoor") }
  let!(:active_member) { FactoryBot.create(:unit_membership, unit: unit) }
  let!(:registered_member) { FactoryBot.create(:unit_membership, :registered, unit: unit) }
  let!(:inactive_member) { FactoryBot.create(:unit_membership, :inactive, unit: unit) }
  let!(:uncontactable_member) do
    FactoryBot.create(:unit_membership, unit: unit).tap { |m| m.update_columns(contactable: false) }
  end

  def cancellation(**attrs)
    described_class.new(event).tap { |c| c.assign_attributes(attrs) }
  end

  describe "#cancel!" do
    it "leaves the event on the calendar as cancelled when no disposition is chosen" do
      expect(cancellation(message_audience: "none").cancel!).to be(true)
      expect(event.reload).to be_cancelled
      expect(event.to_ical_event.status).to eq("CANCELLED")
    end

    it "unpublishes" do
      cancellation(disposition: "unpublish").cancel!
      expect(event.reload).to be_draft
    end

    it "deletes" do
      cancellation(disposition: "delete").cancel!
      expect(Event.exists?(event.id)).to be(false)
    end

    context "when the event is part of a series" do
      let(:parent) { FactoryBot.create(:event, :published, unit: unit) }
      let(:later) { FactoryBot.create(:event, :published, unit: unit, starts_at: 21.days.from_now, ends_at: 22.days.from_now) }

      before do
        [parent, event, later].each { |e| e.update_columns(series_parent_id: parent.id) }
        parent.update_columns(starts_at: 7.days.from_now, ends_at: 8.days.from_now)
      end

      it "cancels only this event unless asked to cancel the series" do
        cancellation(disposition: "cancel", cancel_series: "false").cancel!
        expect(event.reload).to be_cancelled
        expect(later.reload).to be_published
        expect(parent.reload).to be_published
      end

      it "cancels this and later occurrences when asked" do
        cancellation(disposition: "cancel", cancel_series: "true").cancel!
        expect(event.reload).to be_cancelled
        expect(later.reload).to be_cancelled
        expect(parent.reload).to be_published
      end
    end
  end

  describe "notifications" do
    it "sends nothing when the audience is none" do
      expect { cancellation(message_audience: "none").cancel! }.not_to have_enqueued_job(Noticed::EventJob)
    end

    it "notifies active, contactable members" do
      c = cancellation(message_audience: "active_members", message: "Rained out")
      expect { c.cancel! }.to have_enqueued_job(Noticed::EventJob)
      expect(c.recipients).to contain_exactly(active_member)

      notifier = EventCancellationNotifier.last
      expect(notifier.params).to include(title: "Graymoor", note: "Rained out", unit: unit)
      expect(notifier.notifications.map(&:recipient)).to contain_exactly(active_member)
    end

    it "notifies active and registered contactable members" do
      expect(cancellation(message_audience: "all_members").recipients)
        .to contain_exactly(active_member, registered_member)
    end

    it "notifies members who accepted" do
      event.rsvps.create!(member: uncontactable_member, respondent: uncontactable_member, response: :accepted)
      expect(cancellation(message_audience: "acceptors").recipients).to contain_exactly(uncontactable_member)
    end

    it "still notifies when the event is deleted" do
      c = cancellation(message_audience: "active_members", disposition: "delete")
      expect { c.cancel! }.to have_enqueued_job(Noticed::EventJob)
      expect(EventCancellationNotifier.last.params[:title]).to eq("Graymoor")
    end

    it "does not notify about a draft" do
      event.update!(status: :draft)
      expect(cancellation(message_audience: "active_members").recipients).to be_empty
    end
  end
end
