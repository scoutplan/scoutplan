require 'rails_helper'

RSpec.describe 'EventRsvps', type: :request do
  before do
    @admin_user  = FactoryBot.create(:user, email: 'test_admin@scoutplan.org')
    login_as(@admin_user, scope: :user)
  end

  it 'updates a response' do
    @rsvp = FactoryBot.create(:event_rsvp)
    form_params = { event_rsvp: { response: 'accepted' } }
    patch event_rsvp_path(@rsvp), xhr: true, params: form_params

    @rsvp.reload
    expect(@rsvp.response).to eq('accepted')
  end
end
