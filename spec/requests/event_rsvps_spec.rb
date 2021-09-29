require 'rails_helper'

RSpec.describe 'EventRsvps', type: :request do
  before do
    @admin_member = FactoryBot.create(:member, :admin)
    login_as(@admin_member.user, scope: :user)
  end

  it 'updates a response' do
    @rsvp = FactoryBot.create(:event_rsvp)
    post event_rsvps_path(@rsvp.event, member_id: @rsvp.member.id, response: 'accepted'), xhr: true

    @rsvp.reload
    expect(@rsvp.response).to eq('accepted')
  end
end
