describe 'events', type: :feature do
  before :each do
    User.where(email: 'test_admin@scoutplan.org').destroy_all
    User.where(email: 'test_normal@scoutplan.org').destroy_all
    @admin_user = FactoryBot.create(:user, email: 'test_admin@scoutplan.org')
    @normal_user = FactoryBot.create(:user, email: 'test_normal@scoutplan.org')
    @unit = FactoryBot.create(:unit)
    @unit.memberships.create(user: @admin_user, role: 'admin')
    @unit.memberships.create(user: @normal_user, role: 'member')
    @event = FactoryBot.create(:event, unit: @unit)
  end

  it 'shows the add event button to admins' do
    login_as(@admin_user, scope: :user)
    visit unit_events_path(@unit)
    expect(page).to have_selector(:link_or_button, I18n.t('event_add'))
    logout
  end

  it 'hides the add event button to non-admins' do
    login_as(@normal_user, scope: :user)
    visit unit_events_path(@unit)
    expect(page).not_to have_selector(:link_or_button, I18n.t('event_add'))
    logout
  end

  describe 'as an admin...' do
    before :each do
      login_as(@admin_user, scope: :user)
    end

    it 'visits the Event page' do
      path = event_path(@event)
      visit path
      expect(page).to have_current_path(path)
    end

    it 'accesses the Organize page' do
      path = organize_event_path(@event)
      visit path
      expect(page).to have_current_path(path)
    end
  end

  describe 'as a non-admin' do
    before :each do
      login_as(@normal_user, scope: :user)
    end

    it 'visits the Event page' do
      path = event_path(@event)
      visit path
      expect(page).to have_current_path(path)
    end

    it 'hides the New Event button' do
    end

    it 'hides draft events' do
    end

    it 'prevents access to the Organize page' do
    end
  end
end
