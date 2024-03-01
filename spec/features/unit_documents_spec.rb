require "rails_helper"

describe "unit documents", type: :feature, js: true do
  before do
    @admin = FactoryBot.create(:member, :admin)
    @unit = @admin.unit
    login_as(@admin.user, scope: :user)
  end

  describe "upload" do
    it "browses files" do
      visit unit_documents_path(@unit)
      click_on I18n.t("units.documents.upload_form.new_document")
      expect(page).to have_current_path(unit_documents_path(@unit))
    end
  end
end
