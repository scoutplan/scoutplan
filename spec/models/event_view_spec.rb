# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventView, type: :model do
  it 'initializes successfully' do
    event = FactoryBot.build(:event)
    event_view = EventView.new(event)
    expect(event_view).to be
  end
end