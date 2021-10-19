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
    end
  end

  describe 'send_rsvp_confirmation' do
    it 'executes' do
    end
  end
end
