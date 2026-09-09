# frozen_string_literal: true

require "rails_helper"

describe "the event form's side rail", type: :feature do
  before do
    @member = FactoryBot.create(:member, :admin)
    @unit = @member.unit
    @event = FactoryBot.create(:event, :draft, unit: @unit)
    login_as(@member.user, scope: :user)
  end

  describe "category" do
    before { visit edit_unit_event_path(@unit, @event) }

    # event_category is a required belongs_to, so a blank option must not be
    # selectable once one is set - include_blank here broke every save
    it "offers no blank option once a category is set" do
      options = page.all("select[name='event[event_category_id]'] option", visible: :all)

      expect(options.map(&:value)).not_to include("")
    end

    it "keeps the select required" do
      expect(page).to have_css("select[name='event[event_category_id]'][required]", visible: :all)
    end

    it "does not offer inline category creation" do
      values = page.all("select[name='event[event_category_id]'] option", visible: :all).map(&:value)

      expect(values).not_to include("_new")
    end

    it "drops the native chevron" do
      expect(page).to have_css("select[name='event[event_category_id]'].appearance-none", visible: :all)
      expect(page).to have_css("select[name='event[status]'].appearance-none", visible: :all)
    end

    it "carries each category's colour so the glyph can be tinted" do
      # the select lists the unit's own categories, and the event factory's
      # category belongs to a unit of its own, so assign one from this unit
      category = @unit.event_categories.first
      category.update!(color: "#E66425")
      @event.update!(event_category: category)

      visit edit_unit_event_path(@unit, @event)

      expect(page).to have_css(
        "select[name='event[event_category_id]'] option[data-color='#E66425']", visible: :all
      )
    end
  end

  describe "visibility" do
    it "offers draft and published" do
      visit edit_unit_event_path(@unit, @event)

      options = page.all("select[name='event[status]'] option", visible: :all).map(&:value)

      expect(options).to eq(%w[draft published])
    end

    it "shows a cancelled event's status as read-only" do
      @event.update_column(:status, Event.statuses[:cancelled])

      visit edit_unit_event_path(@unit, @event)

      expect(page).to have_no_css("select[name='event[status]']", visible: :all)
      expect(page).to have_content("Cancelled")
    end
  end

  describe "cover photo" do
    it "prompts when there is none" do
      visit edit_unit_event_path(@unit, @event)

      expect(page).to have_content("Add a cover photo")
    end
  end

  describe "chrome" do
    before { visit edit_unit_event_path(@unit, @event) }

    it "drops the horizontal dividers between rail groups" do
      expect(page).to have_no_css("aside .divide-y", visible: :all)
    end

    it "puts the cancel affordance in a danger-zone well in the rail" do
      expect(page).to have_css("aside #cancel_event_button", visible: :all)
      expect(page).to have_content("Danger zone")
    end

    # empty vs populated is CSS-driven off .rail-chip, so both affordances are
    # always in the markup
    it "gives each named group a prompt and a plus" do
      %w[Location Organizers Tags].each { |group| expect(page).to have_content(group) }

      expect(page).to have_css(".rail-group .rail-empty", count: 3, visible: :all)
      expect(page).to have_css(".rail-group .rail-add", count: 3, visible: :all)
    end

    it "sizes the group labels down to match the values" do
      expect(page).to have_css("aside h3.text-xs", minimum: 3, visible: :all)
    end

    it "has no overflow menu in the form's top nav" do
      expect(page).to have_no_css("nav [data-controller='dropdown']", visible: :all)
    end

    it "restores the upload control to the attachments section" do
      expect(page).to have_button("Upload files", count: 1)
    end
  end
end
