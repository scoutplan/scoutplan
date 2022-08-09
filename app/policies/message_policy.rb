# encapsulates Message permission for a UnitMembership
class MessagePolicy < UnitContextPolicy
  def initialize(membership, message)
    @membership = membership
    @message = message
    super
  end

  def index?
    admin?
  end

  def create?
    admin?
  end

  def new?
    admin?
  end

  def edit?
    admin? && @message.editable?
  end
end
