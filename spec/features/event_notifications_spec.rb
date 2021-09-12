# frozen_string_literal: true

describe 'events_notifications', type: :feature do
  it 'does not send notifications for drafts' do
    expect do
      FactoryBot.create(:event, :draft, :requires_rsvp)
    end.to change { ActionMailer::Base.deliveries.count }.by(0)
  end

  it 'sends notifications when published' do
    expect do
      FactoryBot.create(:event, :published, :requires_rsvp)
    end.to change { ActionMailer::Base.deliveries.count }.by(3)
  end
end
