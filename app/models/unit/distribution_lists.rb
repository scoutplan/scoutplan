# frozen_string_literal: true

module Unit::DistributionLists
  include ActionView::Helpers

  def distribution_lists(matching: nil)
    all_distribution_lists.select do |list|
      matching.nil? || list.name =~ /#{matching}/i || list.keywords =~ /#{matching}/i
    end
  end

  private

  def all_distribution_lists
    [
      DistributionList.new(key: "all", name: "Everyone in #{name}", keywords: "everyone",
                           description: pluralize(members.select(&:contactable?).count, 'contactable member')),
      DistributionList.new(key: "active", name: "Active Members", keywords: "everyone",
                           description: pluralize(members.active.select(&:contactable?).count, 'contactable member')),
      DistributionList.new(key: "adults", name: "Active Adults", keywords: "everyone",
                           description: pluralize(members.active.adult.select(&:contactable?).count,
                                                   'contactable member'))
    ]
  end
end
