describe 'events', type: :feature do
  before :each do
    User.where(email: 'test_admin@scoutplan.org').destroy_all
    User.where(email: 'test_normal@scoutplan.org').destroy_all
    @admin_user = FactoryBot.create(:user, email: 'test_admin@scoutplan.org')
    @normal_user = FactoryBot.create(:user, email: 'test_normal@scoutplan.org')
    @unit = FactoryBot.create(:unit)
    @unit.memberships.create(user: @admin_user, role: 'admin')
    @unit.memberships.create(user: @normal_user, role: 'member')
    @event = FactoryBot.create(:event, :draft, unit: @unit, title: 'Draft Event')
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

    it 'shows the add event button to admins' do
      login_as(@admin_user, scope: :user)
      visit unit_events_path(@unit)
      expect(page).to have_selector(:link_or_button, I18n.t('event_add'))
      logout
    end

    it 'accesses the Organize page' do
      path = organize_event_path(@event)
      visit path
      expect(page).to have_current_path(path)
    end

    it 'shows draft events on the index page' do
      visit unit_events_path(@unit)
      expect(page).to have_content('Draft Event')
    end

    it 'displays a Publish button' do
      visit event_path(@event)
      expect(page).to have_selector(:link_or_button, 'Publish')
    end
  end

  describe 'as a non-admin' do
    before :each do
      login_as(@normal_user, scope: :user)
    end

    it 'fails to access a draft Event page' do
      path = event_path(@event)
      expect { visit path }.to raise_error(Pundit::NotAuthorizedError)
    end

    it 'hides the add event button to non-admins' do
      login_as(@normal_user, scope: :user)
      visit unit_events_path(@unit)
      expect(page).not_to have_selector(:link_or_button, I18n.t('event_add'))
      logout
    end

    it 'hides draft events' do
      visit unit_events_path(@unit)
      expect(page).not_to have_content('Draft Event')
    end

    it 'prevents access to the Organize page' do
      expect { visit organize_event_path(@event) }.to raise_error
    end
  end

  describe 'event creation' do
    it 'redirects to Event page after Event draft creation' do
      login_as(@admin_user, scope: :user)
      visit unit_events_path(@unit)
      expect(page).to have_current_path(unit_events_path(@unit))

      # now raise and fill the dialog
      click_link_or_button I18n.t('event_add')
      select('Troop Meeting')
      fill_in 'Title', with: 'Troop Meeting'
      click_button I18n.t('helpers.label.event.accept_button')

      # we should be redirected
      expect(page).to have_content('Troop Meeting was added to the calendar')
    end
  end
end
