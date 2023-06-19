# frozen_string_literal: true

require "rails_helper"

RSpec.describe UnitDigestTask, type: :model do
  before do
    @unit = FactoryBot.create(:unit)
    @task = @unit.tasks.create(key: "digest", type: "UnitDigestTask")
  end

  it "instantiates" do
    expect { UnitDigestTask.new }.not_to raise_exception
  end

  it "performs" do
    expect { @task.perform }.not_to raise_exception
  end

  it "returns the correct description" do
    expect(@task.description).to eq(I18n.t("tasks.unit_digest_description"))
  end

  it "excludes inactive members" do
    FactoryBot.create(:member, unit: @unit, status: :inactive)
    FactoryBot.create(:member, unit: @unit, status: :active)
    @unit.members.each do |member|
      Flipper.enable(:digest, member)
    end
    expect { @task.perform }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
