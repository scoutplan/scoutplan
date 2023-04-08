# frozen_string_literal: true

# Policy class governing Events and what members can do with them
class WikiPagePolicy < UnitContextPolicy
  attr_accessor :page

  def initialize(membership, page)
    super
    @membership = membership
    @page = page
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    admin?
  end

  def edit?
    admin?
  end

  def delete?
    destroy?
  end

  def destroy?
    admin?
  end
end
