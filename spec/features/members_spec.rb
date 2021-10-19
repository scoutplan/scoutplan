describe 'events', type: :feature do
  before :each do
    @admin = FactoryBot.create(:unit_membership, :admin)
    login_as(@admin.user, scope: :user)
  end

  it 'visits the members page' do
    visit unit_members_path(@admin.unit)
  end

  it 'visits a member' do
    member = FactoryBot.create(:unit_membership, unit: @admin.unit)
    visit member_path(member)
  end
end
