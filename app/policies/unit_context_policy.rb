# frozen_string_literal: true

class UnitContextPolicy < ApplicationPolicy
  def initialize(*args)
    super(*args)
    @membership = user
  end

  protected

  def member?
    @membership.present?
  end

  def admin?
    @membership&.role == 'admin'
  end
end
