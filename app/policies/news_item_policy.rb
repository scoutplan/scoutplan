class NewsItemPolicy < UnitContextPolicy
  def initialize(membership, news_item)
    @membership = membership
    @news_item = news_item
  end

  def index?
    admin?
  end

  def destroy?
    admin?
  end
end