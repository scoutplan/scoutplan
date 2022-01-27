# frozen_string_literal: true

require "rails_helper"

describe "home", type: :feature do
  it "navigates to the root url" do
    expect { visit("/") }.not_to raise_error
  end
end
