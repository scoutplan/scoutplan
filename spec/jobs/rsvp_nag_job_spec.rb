require "rails_helper"

RSpec.describe RsvpNagJob, type: :job do
  before do
    @member = FactoryBot.create(:member)
    @unit = @member.unit
    @unit.settings(:communication).update!(config_timestamp: DateTime.current)
  end

  it "performs" do
    expect { RsvpNagJob.new.perform(@unit.id, @unit.settings(:communication).config_timestamp) }.not_to raise_error
  end
end
