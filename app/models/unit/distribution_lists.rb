# frozen_string_literal: true

module Unit::DistributionLists
  def distribution_lists(matching: nil)
    all_distribution_lists.select do |list|
      matching.nil? || list.name =~ /#{matching}/i || list.keywords =~ /#{matching}/i
    end
  end

  private

  def all_distribution_lists
    all_count    = members.count
    active_count = members.active.count
    adult_count  = members.active.adult.count
    [
      DistributionList.new(key: "all", name: "All Members of #{name}", keywords: "everyone",
                           description: "Group with #{all_count} members"),
      DistributionList.new(key: "active", name: "All Active Members of #{name}", keywords: "everyone",
                           description: "Group with #{active_count} members"),
      DistributionList.new(key: "adults", name: "All Active Adults of #{name}", keywords: "everyone",
                           description: "Group with #{adult_count} members")
    ]
  end
end
