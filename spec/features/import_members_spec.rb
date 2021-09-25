# frozen_string_literal: true

describe 'events', type: :feature do
  before :each do
    @member = FactoryBot.create(:member, :admin)
    login_as(@member.user, scope: :user)
  end

  it 'navigates to the import page' do
    location = import_unit_members_path(@member.unit)
    visit location
    expect(page).to have_current_path(location)
    expect(page).to have_content(I18n.t('global.cancel'))
    expect(page).to have_content(I18n.t('members.import.title'))
    expect(page).to have_content(I18n.t('members.import.roster_file'))
    expect(page).to have_selector("input[type=submit][value='Next']")
  end
end
