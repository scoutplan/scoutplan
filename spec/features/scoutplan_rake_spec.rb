# frozen_string_literal: true

require "rails_helper"

Rails.application.load_tasks

describe "scoutplan rake", type: :feature do
  # it "creates an arrival Location" do
  #   @event = FactoryBot.create(:event,
  #                              location: "State Park",
  #                              address: "123 Mountain Road, Faraway, ST  00000")
  #   expect { Rake::Task["scoutplan:create_event_locations"].invoke }.to change { Location.count }.by(1)
  # end

  it "also creates a departure Location" do
    @event = FactoryBot.create(:event,
                               location: "State Park",
                               address: "123 Mountain Road, Faraway, ST  00000",
                               departs_from: "School Parking Lot")
    expect { Rake::Task["scoutplan:create_event_locations"].invoke }.to change { Location.count }.by(2)
  end
end
