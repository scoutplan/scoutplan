# frozen_string_literal: true

require "rails_helper"

describe "messages", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    @second_member = FactoryBot.create(:member, member_type: "adult", unit: @unit,
      first_name: "Mortimer", last_name: "Snerd")
    @third_member = FactoryBot.create(:member, member_type: "adult", unit: @unit,
      first_name: "Mathilda", last_name: "Snerd")
    @fourth_member = FactoryBot.create(:member, member_type: "youth", unit: @unit,
      first_name: "Murgatroyd", last_name: "Snerd")
    @fifth_member = FactoryBot.create(:member, member_type: "youth", unit: @unit,
      first_name: "Matt", last_name: "Snerd")
    @snerds = User.where(last_name: "Snerd").order(:first_name)

    MemberRelationship.create(parent_unit_membership: @second_member, child_unit_membership: @fourth_member)
    MemberRelationship.create(parent_unit_membership: @third_member, child_unit_membership: @fourth_member)

    login_as(@member.user, scope: :user)
    Flipper.enable(:messages)
  end

  describe "authorization" do
    it "navigates to the compose page" do
      visit(new_unit_message_path(@unit))
      expect(page).to have_current_path(new_unit_message_path(@unit))
    end

    it "prevents non-admins from accessing the compose page" do
      @member.update(role: "member")
      visit(new_unit_message_path(@unit))
      expect(page).not_to have_current_path(unit_messages_path(@unit))
    end
  end

  describe "address book", js: true do
    before do
      visit(new_unit_message_path(@unit))
      page.find(:css, "#recipient_search_results li:first-child", visible: false, wait: 5)
    end

    it "displays from address correctly" do
      expect(page).to have_content("#{@member.display_name} at #{@unit.name} <#{@unit.from_address}>")
    end

    describe "search" do
      before do
        fill_in("recipient_search_query_field", with: @second_member.last_name[0, 3])
        find("#recipient_search_results", visible: true, wait: 5)
        expect(page.has_css?("#recipient_search_results", visible: true)).to be_truthy
      end

      it "searches by first name" do
        expect(page).to have_content(@second_member.display_name)
        expect(page).to have_content(@second_member.email)
      end

      it "searches by last name" do
        expect(page).to have_content(@second_member.display_name)
        expect(page).to have_content(@second_member.email)
      end

      it "selects the first result" do
        expect(page).to have_css(".search-result", count: @snerds.count)

        within ".search-result.selected" do
          expect(page).to have_content(@snerds.first.display_name)
        end
      end

      describe "keyboard traversal" do
        it "traverses results with down arrow key" do
          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.second.display_name)
          end

          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.third.display_name)
          end

          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.fourth.display_name)
          end

          # wraparound
          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.first.display_name)
          end
        end

        it "traverses results with down arrow key" do
          # wraparound
          find("#recipient_search_query_field").send_keys :up
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.fourth.display_name)
          end

          find("#recipient_search_query_field").send_keys :up
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.third.display_name)
          end

          find("#recipient_search_query_field").send_keys :up
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.second.display_name)
          end

          find("#recipient_search_query_field").send_keys :up
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.first.display_name)
          end
        end

        it "skips uncontactable results" do
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.first.display_name)
          end

          @snerds.second.update!(email: "anonymous-member-#{SecureRandom.hex(6)}@scoutplan.org")
          find("#recipient_search_query_field").send_keys :down
          
          within ".search-result.selected" do
            expect(page).to have_content(@snerds.third.display_name)
          end
        end
      end
    end

    describe "commit" do
      it "commits via tab" do
        fill_in("recipient_search_query_field", with: @second_member.first_name[0, 3])

        find("#recipient_search_query_field").send_keys :tab
        within ".recipient:first-child .recipient-name" do
          expect(page).to have_content(@second_member.display_name)
        end
      end

      it "commits via return" do
        fill_in("recipient_search_query_field", with: @second_member.first_name[0, 3])

        find("#recipient_search_query_field").send_keys :return
        within ".recipient:first-child .recipient-name" do
          expect(page).to have_content(@second_member.display_name)
        end
      end

      describe "relationships" do
        it "expands youth recipients to include parents" do
          fill_in("recipient_search_query_field", with: @fourth_member.first_name[0, 3])
          find("#recipient_search_query_field").send_keys :return
          expect(page).to have_css(".recipient", count: 3)
        end
      end
    end

    it "toggles the address book" do
      find(:css, "#browse_address_book_button").click
      expect(page.has_css?("#recipient_search_results", visible: true)).to be_truthy
      find(:css, "#browse_address_book_button").click
      expect(page.has_css?("#recipient_search_results", visible: true)).to be_falsey
    end

    describe "groups" do
      it "includes all members group" do
        count = @unit.members.count
        find(:css, "#browse_address_book_button").click
        expect(page).to have_content("All #{@unit.name} Members")
        expect(page).to have_content("Group with #{'member'.pluralize(count)}")
      end

      it "includes active group" do
        count = @unit.members.active.count
        find(:css, "#browse_address_book_button").click
        expect(page).to have_content("All Active #{@unit.name} Members")
        expect(page).to have_content("Group with #{'member'.pluralize(count)}")
      end

      it "includes all adults group" do
        count = @unit.members.adult.count
        find(:css, "#browse_address_book_button").click
        expect(page).to have_content("All Active #{@unit.name} Adult Members")
        expect(page).to have_content("Group with #{'member'.pluralize(count)}")
      end
    end
  end
end
