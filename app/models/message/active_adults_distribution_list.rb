class Message::ActiveAdultsDistributionList < Message::DistributionList
  def id
    "active_adults"
  end

  def recipients
    unit.unit_memberships.active.adult.select(&:contactable?)
  end
end
