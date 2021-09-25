class UserRelationshipsPolicy < ApplicationPolicy
  def create?
    true
  end

  def destroy?
    true
  end
end
