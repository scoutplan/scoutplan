require "minitest/autorun"
require_relative "./date_time_fields"

class ThingWithDate
  extend DateTimeFields
  attr_accessor :happens_at
  date_time_fields_for :happens_at
end

class TestDateTimeFields < MiniTest::Test
  def setup
    @thing = ThingWithDate.new
    # puts @thing.methods
  end

  def test_methods
    assert(@thing.methods.include? :happens_at_date)
    assert(@thing.methods.include? :happens_at_time)
  end

  def test_date_setter
    @thing.happens_at_date = "2006-02-14"
    @thing.happens_at_time = "13:45"
    assert(@thing.happens_at.year == 2006)
    assert(@thing.happens_at.month == 2)
    assert(@thing.happens_at.day == 14)
    assert(@thing.happens_at.hour == 13)
    assert(@thing.happens_at.min == 45)
  end
end
