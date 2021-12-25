# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventNotifier, type: :model do
  describe 'after publish' do
    it 'executes' do
      event = FactoryBot.create(:event, :requires_rsvp)
      Flipper.enable :receive_event_publish_notice
      expect { EventNotifier.after_publish(event) }.to change { ActionMailer::Base.deliveries.count }.by(event.unit.members.count)
    end
  end

  describe 'after_bulk_publish' do
    it 'executes' do
      unit = FactoryBot.create(:unit_with_members)
      Flipper.enable :receive_bulk_publish_notice
      # unit.members.each { |m| Flipper.enable_actor :receive_bulk_publish_notice, m.flipper_id }
      5.times do
        FactoryBot.create(:event, unit: unit, status: :published)
      end
      expect { EventNotifier.after_bulk_publish(unit, unit.events) }.to change { ActionMailer::Base.deliveries.count }.by(unit.members.count)
    end
  end

  describe 'send_rsvp_confirmation' do
    it 'executes' do
    end
  end
end
