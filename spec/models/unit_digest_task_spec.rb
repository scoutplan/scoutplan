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
end
