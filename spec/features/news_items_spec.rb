# frozen_string_literal: true

describe 'news items', type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    login_as @member.user
  end

  it 'navigates to the drafts page' do
    path = unit_newsletter_drafts_path(@member.unit)
    visit path
    expect(page).to have_current_path(path)
  end
end
