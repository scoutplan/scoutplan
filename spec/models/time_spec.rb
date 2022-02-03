# frozen_string_literal: true

require "rails_helper"

RSpec.describe Time, type: :model do
  describe "time_of_day" do
    it "displays morning before noon" do
      expect(Time.now.change(hour: 10).time_of_day).to eq("morning")
    end

    it "displays evening at 7pm" do
      expect(Time.now.change(hour: 19).time_of_day).to eq("evening")
    end

    it "displays afternoon between noon and 6" do
      expect(Time.now.change(hour: 14).time_of_day).to eq("afternoon")
    end
  end
end
