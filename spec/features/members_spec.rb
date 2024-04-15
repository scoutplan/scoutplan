require "rails_helper"

# rubocop:disable Metrics/BlockLength
describe "unit_memberships", type: :feature do
  before do
    User.destroy_all
    @admin = FactoryBot.create(:unit_membership, :admin)
    @unit = @admin.unit
    @non_admin = FactoryBot.create(:unit_membership, :non_admin, unit: @unit)
  end

  describe "as non-admin" do
    before do
      login_as(@non_admin.user, scope: :user)
    end

    it "has a menu item on the unit page" do
      visit(root_path)
      expect(page).to have_content("Members")
    end

    describe "members index (roster)" do
      it "is reachable by a non-admin" do
        path = unit_members_path(@unit)
        visit(path)
        expect(page).to have_current_path(path)
      end

      it "has both members on it" do
        path = unit_members_path(@unit)
        visit(path)
        expect(page).to have_content(@admin.display_name)
        expect(page).to have_content(@non_admin.display_name)
        expect(page).not_to have_content(@admin.email)
        expect(page).not_to have_content(@admin.phone)
        expect(page).not_to have_content(@non_admin.email)
        expect(page).not_to have_content(@non_admin.phone)
      end

      it "displays admin's phone number when enabled" do
        @admin.update(roster_display_phone: true)
        visit(unit_members_path(@unit))
        expect(page).to have_content(@admin.phone.phony_formatted(country_code: "US"))
        expect(page).not_to have_content(@admin.email)
        expect(page).not_to have_content(@non_admin.email)
        expect(page).not_to have_content(@non_admin.phone)
      end

      it "displays admin's email when enabled" do
        @admin.update(roster_display_email: true)
        visit(unit_members_path(@unit))
        expect(page).to have_content(@admin.email)
        expect(page).not_to have_content(@admin.phone.phony_formatted(country_code: "US"))
        expect(page).not_to have_content(@non_admin.email)
        expect(page).not_to have_content(@non_admin.phone.phony_formatted(country_code: "US"))
      end
    end

    describe "show" do
      it "isn't reachable" do
        path = unit_unit_membership_path(@unit, @admin)
        visit(path)
        expect(page).not_to have_current_path(path)
      end
    end

    describe "edit" do
      it "isn't reachable" do
        path = edit_unit_unit_membership_path(@unit, @admin)
        visit(path)
        expect(page).not_to have_current_path(path)
      end
    end

    describe "new" do
      it "isn't reachable" do
        path = new_unit_unit_membership_path(@unit, @admin)
        visit(path)
        expect(page).not_to have_current_path(path)
      end
    end
  end

  describe "as admin" do
    before do
      login_as(@admin.user, scope: :user)
    end

    describe "index" do
      it "is reachable" do
        path = unit_members_path(@unit)
        visit path
        expect(page).to have_current_path(path)
      end

      it "shows emails and addresses independent of preferences" do
        visit(unit_members_path(@unit))
        expect(page).to have_content(@admin.display_name)
        expect(page).to have_content(@non_admin.display_name)
        expect(page).to have_content(@admin.email)
        expect(page).to have_content(@admin.phone.phony_formatted(country_code: "US"))
        expect(page).to have_content(@non_admin.email)
        expect(page).to have_content(@non_admin.phone.phony_formatted(country_code: "US"))
      end
    end

    it "visits a member" do
      member = FactoryBot.create(:unit_membership, unit: @unit)
      visit unit_member_path(@unit, member)
      expect(page).to have_current_path unit_member_path(@unit, member)
    end

    it "creates a member" do
      visit unit_members_path(@unit)
      click_link_or_button I18n.t("members.index.new_button_caption")

      # fill in the new member form
      fill_in "unit_membership_user_attributes_first_name", with: Faker::Name.first_name
      fill_in "unit_membership_user_attributes_last_name", with: Faker::Name.last_name
      fill_in "unit_membership_user_attributes_email", with: Faker::Internet.email
      fill_in "unit_membership_user_attributes_phone", with: Faker::PhoneNumber.phone_number
      choose "unit_membership_member_type_youth"
      choose "unit_membership_status_active"
      # check "settings_communication_via_email"
      # check "settings_communication_via_sms"

      # click the button
      expect { click_link_or_button "Add This Member" }.to change { UnitMembership.all.count }.by 1
      expect(page).to have_current_path unit_members_path(@unit)

      # fetch the newly-created member
      member = UnitMembership.last

      # flash message
      # expect(page).to have_content(I18n.t("members.confirmations.create", member_name: member.full_display_name, unit_name: @unit.name))
    end

    it "creates a member without email and phone" do
      visit unit_members_path(@unit)
      click_link_or_button I18n.t("members.index.new_button_caption")

      # fill in the new member form
      fill_in "unit_membership_user_attributes_first_name", with: Faker::Name.first_name
      fill_in "unit_membership_user_attributes_last_name", with: Faker::Name.last_name
      choose "unit_membership_member_type_youth"
      choose "unit_membership_status_active"
      # check "settings_communication_via_email"
      # check "settings_communication_via_sms"

      # click the button
      expect { click_link_or_button "Add This Member" }.to change { UnitMembership.all.count }.by 1
      expect(page).to have_current_path unit_members_path(@unit)

      # fetch the newly-created member
      member = UnitMembership.last
      # expect(member.anonymous_email?).to be_truthy

      # flash message
      # expect(page).to have_content(I18n.t("members.confirmations.create", member_name: member.full_display_name, unit_name: @unit.name))
    end

    it "creates a member with an existing user" do
      member = FactoryBot.create(:member)

      visit unit_members_path(@unit)
      click_link_or_button I18n.t("members.index.new_button_caption")

      # fill in the new member form
      fill_in "unit_membership_user_attributes_first_name", with: member.first_name
      fill_in "unit_membership_user_attributes_last_name", with: member.last_name
      fill_in "unit_membership_user_attributes_email", with: member.email
      choose "unit_membership_member_type_youth"
      choose "unit_membership_status_active"
      # check "settings_communication_via_email"
      # check "settings_communication_via_sms"

      # click the button
      expect { click_link_or_button "Add This Member" }.to change { UnitMembership.all.count }.by 1
      expect(page).to have_current_path unit_members_path(@unit)
    end

    it "edits a member's user attributes" do
      member = FactoryBot.create(:member, unit: @admin.unit)
      visit edit_unit_member_path(@unit, member)

      new_name = "A different name"
      new_phone = "A different phone"
      fill_in "unit_membership_user_attributes_first_name", with: new_name
      fill_in "unit_membership_user_attributes_phone", with: new_phone
      click_link_or_button I18n.t("members.form.captions.accept_update")
      member.reload
      expect(member.first_name).to eq(new_name)
      expect(member.phone).to eq(new_phone)
    end

    it "edits a member's email address" do
      member = FactoryBot.create(:member, unit: @unit)
      visit edit_unit_member_path(@unit, member)

      new_email = Faker::Internet.email
      fill_in "unit_membership_user_attributes_email", with: new_email
      click_link_or_button I18n.t("members.form.captions.accept_update")
      member.reload
      expect(member.email).to eq(new_email)
    end
  end
end
# rubocop:enable Metrics/BlockLength
