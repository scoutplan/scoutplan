# frozen_string_literal: true

describe 'news items', type: :feature do
  before do
    @membership = FactoryBot.create(:unit_membership)
  end

  it 'navigates to the drafts page' do
    visit unit_newsletter_drafts_path(@membership.unit)
  end
end
