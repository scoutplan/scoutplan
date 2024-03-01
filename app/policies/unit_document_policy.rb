class UnitDocumentPolicy < UnitContextPolicy
  def index?
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

  def tag?
    index?
  end

  def bulk_updated?
    update?
  end
end
