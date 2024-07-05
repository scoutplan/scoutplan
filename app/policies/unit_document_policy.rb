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

  def batch_update?
    update?
  end

  def batch_delete?
    destroy?
  end
end
