# frozen_string_literal: true

module Unit::DistributionLists
  def distribution_lists(matching: nil)
    all_distribution_lists.select do |list|
      matching.nil? || list.name =~ /#{matching}/i || list.keywords =~ /#{matching}/i
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def all_distribution_lists
    [
      DistributionList.new(key: "all", name: "All #{name} Members", keywords: "everyone",
                           description: "Group with #{'member'.pluralize(members.count)}"),
      DistributionList.new(key: "active", name: "All Active #{name} Members", keywords: "everyone",
                           description: "Group with #{'member'.pluralize(members.active.count)}"),
      DistributionList.new(key: "adults", name: "All Active #{name} Adult Members", keywords: "everyone",
                           description: "Group with #{'member'.pluralize(members.active.adult.count)}")
    ]
  end
  # rubocop:enable Metrics/AbcSize
end
