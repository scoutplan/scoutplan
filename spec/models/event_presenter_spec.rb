# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Event, type: :model do
  before do
    @current_member = FactoryBot.create(:member)
    @presenter = EventPresenter.new(current_member: @current_member)
  end

  describe 'family_context_name' do
    it 'appends (you) to current user' do
      expect(@presenter.family_context_name(@current_member)).to eq("#{@current_member.display_first_name} (you)")
    end

    # it 'does not append (you) to everyone else' do
    #   another_member = FactoryBot.build(:member)
    #   expect(@presenter.family_context_name(another_member)).to eq("#{@current_member.display_first_name}")
    # end
  end
end
