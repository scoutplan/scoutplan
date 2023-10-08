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
    (admin? || @message.author == @membership) && @message.editable?
  end

  def draft?
    admin?
  end

  def duplicate?
    admin? || @message.author == @membership
  end
end
