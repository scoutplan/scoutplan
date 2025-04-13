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
    description_all = pluralize(members.includes(:user).select(&:contactable?).count, "contactable member")
    description_active = pluralize(members.active.includes(:user).select(&:contactable?).count, "contactable member")
    description_adults = pluralize(members.active.includes(:user).adult.select(&:contactable?).count,
                                   "contactable member")

    # description_all = ""
    # description_active = ""
    # description_adults = ""

    [
      DistributionList.new(key: "all", name: "Everyone in #{name}", keywords: "everyone", description: description_all),
      DistributionList.new(key: "active", name: "Active Members", keywords: "everyone",
                           description: description_active),
      DistributionList.new(key: "adults", name: "Active Adults", keywords: "everyone", description: description_adults)
    ]
  end
end
