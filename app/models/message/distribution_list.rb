class Message::DistributionList
  include GlobalID::Identification

  attr_reader :unit

  def id
    raise NotImplementedError, "You must implement the id method in a subclass"
  end

  def self.find(id)
    case id
    when "everyone"
      Message::EveryoneDistributionList.new(Current.unit)
    when "all_active"
      Message::AllActiveDistributionList.new(Current.unit)
    when "active_adults"
      Message::ActiveAdultsDistributionList.new(Current.unit)
    else
      raise ActiveRecord::RecordNotFound, "Distribution list not found"
    end
  end

  def initialize(unit)
    @unit = unit
  end

  def description
    "#{recipients.count} contactable recipient".pluralize(recipients.count)
  end

  def recipients
    []
  end
end
