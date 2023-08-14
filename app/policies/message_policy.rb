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
    admin? || members_can_write_announcements?
  end

  def new?
    admin? || members_can_write_announcements?
  end

  def edit?
    (admin? && @message.editable?) || @message.author == @membership
  end

  private

  def members_can_write_announcements?
    false
  end
end
