# frozen_string_literal: true

class UnitContextPolicy < ApplicationPolicy
  # attr_reader :user, :unit

  # def initialize(user, unit)
  #   @user = user
  #   @unit = unit
  #   @membership = @unit.membership_for(@user)
  # end

  def initialize(*args)
    super(*args)
    @membership = user
  end

  protected

  def is_member?
    @membership.present?
  end

  def is_admin?
    is_member? && @membership.role == 'admin'
  end

  def admin?
    is_admin?
  end
end
