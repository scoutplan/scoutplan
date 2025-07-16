class Message::EveryoneDistributionList < Message::DistributionList
  LIST_ID = "everyone".freeze

  def id
    LIST_ID
  end

  def recipients
    unit.unit_memberships.contactable?
  end
end
