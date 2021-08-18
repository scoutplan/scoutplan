class EventPolicy < ApplicationPolicy
  def create?
    true
  end

  def edit?
    true
  end
end
