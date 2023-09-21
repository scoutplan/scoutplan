# frozen_string_literal: true

module Unit::DistributionLists
  def distribution_lists(matching: nil)
    ap matching
    all_distribution_lists.select do |list|
      matching.nil? || list.name =~ /#{matching}/i
    end
  end

  private

  def all_distribution_lists
    [
      DistributionList.new(key: "dl_all",    name: "All #{name} Members",          description: "Group with 48 members"),
      DistributionList.new(key: "dl_active", name: "All #{name} Active Members",   description: "Group with 28 members"),
      DistributionList.new(key: "dl_adults", name: "Active #{name} Adult Members", description: "Group with 28 members")
    ]
  end
end
