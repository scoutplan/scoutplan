# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRelationship, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.create(:user_relationship)).to be_valid
  end

  describe 'validations' do
    it 'prevents duplicates' do
      example = FactoryBot.create(:user_relationship)
      dupe = FactoryBot.build(:user_relationship, parent: example.parent, child: example.child)
      expect(dupe).not_to be_valid
    end

    it 'requires a parent' do
      expect(FactoryBot.build(:user_relationship, parent: nil)).not_to be_valid
    end

    it 'requires a child' do
      expect(FactoryBot.build(:user_relationship, child: nil)).not_to be_valid
    end
  end

  describe 'relationships' do
    before do
      @parent = FactoryBot.create(:user)
      @child = FactoryBot.create(:child)
      @parent.child_relationships.create(child: @child)
    end

    it 'establishes child relationship' do
      expect(@parent.children).to include(@child)
    end

    it 'establishes parent relationship' do
      expect(@child.parents).to include(@parent)
    end
  end
end
