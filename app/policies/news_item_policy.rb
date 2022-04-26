# frozen_string_literal: true

# Policy for writing News Items
class NewsItemPolicy < UnitContextPolicy
  def initialize(membership, news_item)
    super
    @membership = membership
    @news_item = news_item
  end

  def index?
    admin?
  end

  def destroy?
    admin?
  end

  def edit?
    admin?
  end

  def update?
    admin?
  end

  def create?
    admin?
  end
end