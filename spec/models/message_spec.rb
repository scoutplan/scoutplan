require "rails_helper"

RSpec.describe Message, type: :model do
  before do
    @adult = FactoryBot.create(:member)
    @unit = @adult.unit
    @youth = FactoryBot.create(:member, :youth, unit: @unit)
  end

  describe "resolve recipients" do
    it "resolves actives" do
    end

    it "resolves registered" do
    end

    it "limits to adults" do
    end

    it "includes parents" do
    end
  end
end
