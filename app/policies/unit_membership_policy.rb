# frozen_string_literal: true

class UnitMembershipPolicy < UnitContextPolicy
  # def initialize(current_member, target_member)
  #   super
  #   # @membership = current_member
  # end

  def index?
    true
  end

  def show?
    admin?
  end

  def create?
    admin?
  end

  def edit?
    admin? || self? || child?
  end

  def update?
    edit?
  end

  def new?
    admin?
  end

  def invite?
    admin?
  end

  def calendar?
    edit?
  end

  private

  def child?
    @membership.children.include?(@target)
  end

  def self?
    @membership == @target
  end
end
