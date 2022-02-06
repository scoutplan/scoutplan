# frozen_string_literal: true

require "rails_helper"

describe "events", type: :feature do
  it "redirects bogus magic links" do
    visit("/bogus")
    expect(page).to have_current_path(root_path)
  end
end
