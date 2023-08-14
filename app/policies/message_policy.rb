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

  def create_pending?
    draft?
  end

  def new?
    draft?
  end

  def edit?
    (admin? && @message.editable?) || @message.author == @membership
  end

  def draft?
    admin?
  end
end
