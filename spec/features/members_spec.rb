describe 'unit_memberships', type: :feature do
  before do
    @admin = FactoryBot.create(:unit_membership, :admin)
    login_as(@admin.user, scope: :user)
  end

  it 'visits the members page' do
    path = unit_members_path(@admin.unit)
    visit path
    expect(page).to have_current_path(path)
  end

  it 'visits a member' do
    member = FactoryBot.create(:unit_membership, unit: @admin.unit)
    visit member_path(member)
  end
end
