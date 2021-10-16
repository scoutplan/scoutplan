# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WeeklyDigestSender, type: :model do
  it 'performs' do
    sender = WeeklyDigestSender.new
    sender.perform
  end
end
