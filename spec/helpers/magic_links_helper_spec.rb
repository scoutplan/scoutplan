# frozen_string_literal: true

require "rails_helper"

# Specs in this file have access to a helper object that includes
# the MagicLinksHelper. For example:
#
# describe MagicLinksHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe MagicLinksHelper, type: :helper do
  before do
    @member = FactoryBot.create(:member)
    @event = FactoryBot.create(:event, unit: @member.unit)
  end

  it "works" do
    expect { magic_link_to(@member, @event.title, @event) }.not_to raise_exception
  end
end
