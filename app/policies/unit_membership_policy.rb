# frozen_string_literal: true

class UnitMembershipPolicy < UnitContextPolicy
  def initialize(membership, target_membership)
    super(membership, target_membership)
    @target_membership = target_membership
  end

  def index?
    admin?
  end

  def show?
    admin?
  end

  def create?
    true
  end

  def edit?
    admin?
  end

  def new?
    admin?
  end
end
