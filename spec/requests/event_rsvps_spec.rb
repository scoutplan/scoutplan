require 'rails_helper'

RSpec.describe 'EventRsvps', type: :request do
  before do
    @admin_user  = FactoryBot.create(:user, email: 'test_admin@scoutplan.org')
    login_as(@admin_user, scope: :user)
  end

  it 'updates a response' do
    @rsvp = FactoryBot.create(:event_rsvp)
    post event_rsvps_path(@rsvp.event, user_id: @rsvp.user.id, response: 'accepted'), xhr: true

    @rsvp.reload
    expect(@rsvp.response).to eq('accepted')
  end
end
