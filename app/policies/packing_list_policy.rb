# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class PackingListPolicy < UnitContextPolicy
  def initialize(membership, packing_list)
    super
    @membership = membership
    @packing_list = packing_list
  end

  def show?
    admin?
  end

  def edit_rsvps?
    true
  end

  def create?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end
end
