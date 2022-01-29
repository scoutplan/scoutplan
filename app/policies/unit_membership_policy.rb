# frozen_string_literal: true

class UnitMembershipPolicy < UnitContextPolicy
  # def initialize(current_member, target_member)
  #   ap current_member
  #   super
  #   # @membership = current_member
  # end

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
