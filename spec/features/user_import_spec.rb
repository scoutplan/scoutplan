describe 'events_notifications', type: :feature do
  before do
    @admin_user = FactoryBot.create(:user)
    @unit = FactoryBot.create(:unit)
    @unit.memberships.create(user: @admin_user)
    login_as(@admin_user, scope: :user)
  end

  it 'navigates to the import page' do
    path = import_unit_members_path(@unit)
    visit path
    expect(page).to have_current_path(path)
  end
end
