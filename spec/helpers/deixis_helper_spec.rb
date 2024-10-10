require "rails_helper"

# Specs in this file have access to a helper object that includes
# the FamilyRsvpsHelper. For example:
#
# describe FamilyRsvpsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe DeixisHelper, type: :helper do
  describe "temporal_deictic_expression" do
    it "returns 'today' for today" do
      expect(helper.temporal_deictic_expression(Time.zone.now)).to eq("today")
    end

    it "returns 'tomorrow' for tomorrow" do
      expect(helper.temporal_deictic_expression(1.day.from_now)).to eq("tomorrow")
    end

    it "returns 'yesterday' for yesterday" do
      expect(helper.temporal_deictic_expression(1.day.ago)).to eq("yesterday")
    end

    it "returns 'in 3 days' for 3 days from now" do
      expect(helper.temporal_deictic_expression(3.days.from_now)).to eq("in 3 days")
    end

    it "returns '3 days ago' for 3 days ago" do
      expect(helper.temporal_deictic_expression(3.days.ago)).to eq("3 days ago")
    end
  end
end
