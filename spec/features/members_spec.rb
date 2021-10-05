describe 'events', type: :feature do
  before :each do
    @admin = FactoryBot.create(:unit_membership, :admin)
    login_as(@admin, scope: :user)
  end

  describe 'visits members page' do
    describe 'with unspecified member type' do
    end
  end
end
