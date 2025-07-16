class Message::AllActiveDistributionList < Message::DistributionList
  def id
    "all_active"
  end

  def recipients
    unit.unit_memberships.active.select(&:contactable?)
  end
end
