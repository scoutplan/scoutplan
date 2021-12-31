class MessagePolicy < UnitContextPolicy
  def initialize(membership, message)
    @membership = membership
    @message = message
  end

  def index?
    admin?
  end

  def create?
  end
end