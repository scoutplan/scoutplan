# frozen_string_literal: true

require "rails_helper"

RSpec.describe Event, type: :model do
  before do
    @member = FactoryBot.create(:member)
  end

  describe "single_day" do
    it "handles same-day events" do
      event = FactoryBot.build(
        :event,
        starts_at: Time.now.beginning_of_day + 1.hour,
        ends_at: Time.now.beginning_of_day + 2.hours
      )
      presenter = EventPresenter.new(event, @member)
      expect(presenter.single_day?).to be_truthy
    end

    it "handles multi-day events" do
      event = FactoryBot.build(
        :event,
        starts_at: Time.now.beginning_of_day + 1.hour,
        ends_at: Time.now.beginning_of_day + 26.hours
      )
      presenter = EventPresenter.new(event, @member)
      expect(presenter.single_day?).to be_falsey
    end
  end

  describe "family_context_name" do
    it "appends (you) to current user" do
      presenter = EventPresenter.new(nil, @member)
      expect(presenter.family_context_name(@member)).to eq("#{@member.display_first_name} (you)")
    end
  end
end
