# frozen_string_literal: true

require "rails_helper"

describe "messages", type: :feature do
  skip "can't get these to run reliably"

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
    @family = User.where(last_name: "Snerd").order(:first_name)

    MemberRelationship.create(parent_unit_membership: @second_member, child_unit_membership: @fourth_member)
    MemberRelationship.create(parent_unit_membership: @third_member, child_unit_membership: @fourth_member)

    @event = FactoryBot.create(:event, :published, :requires_rsvp, unit: @unit,
      starts_at: 7.days.from_now, ends_at: 8.days.from_now, rsvp_closes_at: 6.days.from_now)

    @event.rsvps.create!(unit_membership: @second_member, response: :accepted, respondent: @second_member)

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

  describe "message compose", :skip, js: true do
    before do
      visit(new_unit_message_path(@unit))
    end

    describe "attachments" do
      it "attaches a file" do
        filename = Rails.root.join("spec", "fixtures", "files", "roster_file.csv")
        visit(new_unit_message_path(@unit))
        execute_script("document.querySelector('#file_attachment_form').classList.remove('hidden');")
        page.attach_file("files", filename)
        find("#attachment_submit_button", visible: false).click

        expect(page).to have_css("#attachments_section")
        expect(page).to have_css(".attachment-candidate", count: 1)
      end
    end

    describe "address book" do
      before do
        page.find("#test_mode", visible: false).set("true")
        page.find(:css, "#recipient_search_results li:first-child", visible: false, wait: 10)
      end

      it "toggles the address book" do
        find(:css, "#browse_address_book_button").click
        expect(page).to have_css("#recipient_search_results", visible: true)
        find(:css, "#browse_address_book_button").click
        expect(page).to have_css("#recipient_search_results", visible: false)
      end

      describe "search" do
        before do
          # find("#recipient_search_query_field").click
        end

        it "searches by first name" do
          find("#recipient_search_query_field").click
          fill_in("recipient_search_query_field", with: @family.first.first_name[0, 3])
          expect(page).to have_content(@family.first.display_name)
          expect(page).to have_content(@family.first.email)
        end

        it "searches by last name" do
          fill_in("recipient_search_query_field", with: @family.first.last_name[0, 3])
          expect(page).to have_content(@family.first.display_name, wait: 5)
          expect(page).to have_content(@family.first.email)
        end

        it "searches by event name" do
          find("#recipient_search_query_field").click
          fill_in("recipient_search_query_field", with: @event.title[0, 3])
          find("#recipient_search_results", visible: true, wait: 5)
          within "#recipient_search_results" do
            expect(page).to have_content(@event.title)
            expect(page).to have_content("attendee".pluralize(@event.rsvps.accepted.count))
          end
        end

        it "defaults to the first result" do
          fill_in("recipient_search_query_field", with: @family.first.last_name[0, 3])
          expect(page).to have_css(".search-result", count: @family.count)

          within ".search-result.selected", visible: false do
            expect(page).to have_content(@family.first.display_name)
          end
        end

        it "traverses results with down arrow key" do
          fill_in("recipient_search_query_field", with: @family.first.last_name[0, 3])
          expect(page).to have_css(".search-result", count: @family.count)

          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@family.second.display_name)
          end

          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@family.third.display_name)
          end

          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@family.fourth.display_name)
          end

          # wraparound
          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@family.first.display_name)
          end
        end

        it "traverses results with up arrow key" do
          fill_in("recipient_search_query_field", with: @family.first.last_name[0, 3])
          expect(page).to have_css(".search-result", count: @family.count)

          # wraparound
          find("#recipient_search_query_field").send_keys :up
          within ".search-result.selected" do
            expect(page).to have_content(@family.fourth.display_name)
          end

          find("#recipient_search_query_field").send_keys :up
          within ".search-result.selected" do
            expect(page).to have_content(@family.third.display_name)
          end

          find("#recipient_search_query_field").send_keys :up
          within ".search-result.selected" do
            expect(page).to have_content(@family.second.display_name)
          end

          find("#recipient_search_query_field").send_keys :up
          within ".search-result.selected" do
            expect(page).to have_content(@family.first.display_name)
          end
        end

        it "skips uncontactable results" do
          @family.second.update!(email: "anonymous-member-#{SecureRandom.hex(6)}@scoutplan.org")
          visit(new_unit_message_path(@unit))
          page.find("#test_mode", visible: false).set("true")
          page.find(:css, "#recipient_search_results li:first-child", visible: false, wait: 10)

          fill_in("recipient_search_query_field", with: "")
          fill_in("recipient_search_query_field", with: @family.first.last_name[0, 3])

          find("#recipient_search_query_field").send_keys :down
          within ".search-result.selected" do
            expect(page).to have_content(@family.third.display_name)
          end
        end
      end

      describe "commit" do
        it "commits via tab" do
          fill_in("recipient_search_query_field", with: @second_member.first_name[0, 3])

          find("#recipient_search_query_field").send_keys :tab
          find(".recipient:first-child", wait: 10)
          within ".recipient:first-child .recipient-name" do
            expect(page).to have_content(@second_member.display_name)
          end
        end

        it "commits via return" do
          fill_in("recipient_search_query_field", with: @second_member.first_name[0, 3])

          find("#recipient_search_query_field").send_keys :return
          find(".recipient:first-child", wait: 10)
          within ".recipient:first-child .recipient-name" do
            expect(page).to have_content(@second_member.display_name)
          end
        end

        it "expands youth recipients to include parents" do
          fill_in("recipient_search_query_field", with: @fourth_member.first_name[0, 3])
          find("#recipient_search_query_field").send_keys :return
          expect(page).to have_css(".recipient", count: 3)
        end

        it "removes committed results from the search results" do
          fill_in("recipient_search_query_field", with: @family.first.last_name)
          find("#recipient_search_query_field").send_keys :return
          find(".recipient:first-child", wait: 10)

          fill_in("recipient_search_query_field", with: @family.first.last_name)

          within "#recipient_search_results" do
            expect(page).not_to have_content(@family.first.display_name)
          end
        end

        it "prevents duplicate recipients" do
          find("#recipient_search_query_field").click
          fill_in("recipient_search_query_field", with: @event.rsvps.first.member.last_name)
          find("#recipient_search_query_field").send_keys :return

          expect(page).to have_css(".recipient", count: 1)

          fill_in("recipient_search_query_field", with: @event.title[0, 3])
          find("#recipient_search_query_field").send_keys :return
          find(".recipient:first-child", wait: 10)

          expect(page).to have_css(".recipient", count: 1)
        end
      end

      describe "remove" do
        before do
          fill_in("recipient_search_query_field", with: @fourth_member.first_name[0, 3])
          find("#recipient_search_query_field").send_keys :return
          expect(page).to have_css(".recipient", count: 3)
        end

        it "removes a recipient via the 'X' button" do
          expect(page).to have_css(".recipient", count: 3)
          find(".recipient:first-child .recipient-action-delete").click
          expect(page).to have_css(".recipient", count: 2)
        end

        it "removes a recipient via backspace" do
          expect(page).to have_css(".recipient", count: 3)
          find("#recipient_search_query_field").send_keys :backspace
          expect(page).to have_css(".recipient", count: 2)
        end

        it "removes all recipients via Cmd+Backspace" do
          expect(page).to have_css(".recipient", count: 3)
          find("#recipient_search_query_field").send_keys [:meta, :backspace]
          expect(page).to have_css(".recipient", count: 0)
        end
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

      describe "validation" do
        before do
          visit(new_unit_message_path(@unit))
          page.find("#test_mode", visible: false).set("true")
          page.find(:css, "#recipient_search_results li:first-child", visible: false, wait: 10)
        end

        it "disables the send button when there's no recipients" do
          expect(page).to have_button(I18n.t("messages.captions.send_message"), disabled: true)
        end

        it "enables the send button when there's a recipient" do
          fill_in("recipient_search_query_field", with: @fourth_member.first_name[0, 3])
          find("#recipient_search_query_field").send_keys :return
          expect(page).to have_css(".recipient", count: 3)

          expect(page).to have_button(I18n.t("messages.captions.send_message"))
          expect(page).to have_css("#send_preview_button")
        end
      end
    end
  end
end
