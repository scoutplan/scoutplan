# frozen_string_literal: true

module Unit::DistributionLists
  include ActionView::Helpers

  def distribution_lists(matching: nil)
    all_distribution_lists.select do |list|
      matching.nil? || list.name =~ /#{matching}/i || list.keywords =~ /#{matching}/i
    end
  end

  private

  # rubocop:disable Metrics/AbcSize
  def all_distribution_lists
    description_all = pluralize(members.includes(:user).select(&:contactable?).count, "contactable member")
    description_active = pluralize(members.active.includes(:user).select(&:contactable?).count, "contactable member")
    description_adults = pluralize(members.active.includes(:user).adult.select(&:contactable?).count,
                                   "contactable member")

    result = [
      DistributionList.new(key: "all", name: "Everyone in #{name}", keywords: "everyone", description: description_all),
      DistributionList.new(key: "active", name: "Active Members", keywords: "everyone",
                           description: description_active),
      DistributionList.new(key: "adults", name: "Active Adults", keywords: "everyone", description: description_adults)
    ]

    # unique UnitMembership tags
    tags = unit.unit_memberships.tag_counts_on(:tags)

    tags.each do |tag|
      result << DistributionList.new(
        key:         "tag:#{tag.id}",
        name:        "Members with tag: #{tag.name}",
        keywords:    "tag #{tag.name}",
        description: pluralize(members.tagged_with(tag).includes(:user).select(&:contactable?).count,
                               "contactable member")
      )
    end

    result
  end
  # rubocop:enable Metrics/AbcSize
end
