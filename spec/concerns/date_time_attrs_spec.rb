# frozen_string_literal: true

require "rails_helper"

class ThingWithDate
  extend DateTimeAttributes
  date_time_attrs_for :happens_at

  attr_accessor :happens_at
end

RSpec.describe ThingWithDate, type: :model do
  before do
    @thing = ThingWithDate.new
  end

  describe "new methods" do
    it "gets nil" do
      expect(@thing.happens_at_date).to be_nil
      expect(@thing.happens_at_time).to be_nil
    end

    it "gets attributes" do
      @thing.happens_at = DateTime.now
      expect(@thing.happens_at_date).to be_a(Date)
      expect(@thing.happens_at_time).to be_a(Time)
    end

    it "sets attributes" do
      @thing.happens_at_date = "2006-02-14"
      @thing.happens_at_time = "13:45"
      expect(@thing.happens_at.year).to  eq(2006)
      expect(@thing.happens_at.month).to eq(2)
      expect(@thing.happens_at.day).to   eq(14)
      expect(@thing.happens_at.hour).to  eq(13)
      expect(@thing.happens_at.min).to   eq(45)
    end
  end
end
