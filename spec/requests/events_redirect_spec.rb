# frozen_string_literal: true

require "rails_helper"

describe "redirection", type: :request do
  before do
    @member = FactoryBot.create(:member)
  end

  it "redirects /events paths" do
    get "/units/#{@member.unit.to_param}/events/list"
    expect(response).to redirect_to(list_unit_events_path(@member.unit))
  end
end
