# frozen_string_literal: true

class UnitMembershipPolicy < UnitContextPolicy
  def initialize(membership, target_membership)
    super(membership, target_membership)
    @target_membership = target_membership
  end

  def index?
    is_admin?
  end

  def show?
    is_admin?
  end

  def create?
    true
  end

  def edit?
    true
  end

  def new?
    is_admin?
  end
end
