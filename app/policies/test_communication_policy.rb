# frozen_string_literal: true

# what actions can a member take on a TestCommunication?
class TestCommunicationPolicy < UnitContextPolicy
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
end
