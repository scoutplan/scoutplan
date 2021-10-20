# frozen_string_literal: true

describe 'the sign-in process', type: :feature do
  before :each do
    User.destroy_all
    @user = FactoryBot.create(:user, email: 'test@scoutplan.org')
    @unit = FactoryBot.create(:unit)
    @membership = @unit.unit_memberships.create(user: @user, status: :active, role: 'member')
  end

  it 'signs in and redirects' do
    visit new_user_session_path
    fill_in 'user_email', with: @user.email
    fill_in 'user_password', with: 'password'
    click_button 'Log in'
    expect(page).to have_current_path(unit_home_path(@unit.id, @unit.slug))
  end
end
