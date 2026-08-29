require "rails_helper"

describe "unit documents", type: :feature, js: true do
  before do
    @admin = FactoryBot.create(:member, :admin)
    @unit = @admin.unit
    login_as(@admin.user, scope: :user)
  end

  describe "upload" do
    it "attaches a browsed file to the unit" do
      visit unit_documents_path(@unit)
      expect(page).to have_button(I18n.t("units.documents.upload_form.new_document"))

      # The button only opens the OS file picker (upload#browse clicks the hidden
      # input), and Capybara can't drive that dialog, so attach to the input itself.
      # It sits inside a .hidden wrapper, which :make_visible can't see past.
      page.execute_script(
        "document.getElementById('upload_document_field').closest('.hidden').classList.remove('hidden')"
      )
      attach_file("upload_document_field",
                  Rails.root.join("spec/support/test_member_import_with_me.csv"))

      expect(page).to have_css("#documents_table_body", text: "test_member_import_with_me")
      expect(@unit.documents.count).to eq(1)
    end
  end
end
