# frozen_string_literal: true

describe 'events', type: :feature do
  before :each do
    @member = FactoryBot.create(:member, :admin)
    login_as(@member.user, scope: :user)
  end

  after do
    User.where(email: 'doctor@dre.md').destroy_all
  end

  # it 'navigates to the import page' do
  #   location = import_unit_members_path(@member.unit)
  #   visit location
  #   expect(page).to have_current_path(location)
  #   expect(page).to have_content(I18n.t('global.cancel'))
  #   expect(page).to have_content(I18n.t('members.import.title'))
  #   expect(page).to have_content(I18n.t('members.import.roster_file'))
  #   expect(page).to have_selector("input[type=submit][value='Next']")
  # end

  # # this turned out to be hard. See https://stackoverflow.com/questions/7260394/test-a-file-upload-using-rspec-rails
  # it 'imports' do
  #   FactoryBot.create(:user, email: 'doctor@dre.md')
  #   location = import_unit_members_path(@member.unit)
  #   visit location
  #   attach_file 'roster_file', Rails.root.join('spec', 'fixtures', 'files', 'roster_file.csv')
  #   click_link_or_button 'Next'
  # end
end
