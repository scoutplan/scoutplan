class UnitSettingsPolicy < UnitContextPolicy
  def initialize(membership, target_membership)
    super(membership, target_membership)
    @target_membership = target_membership
  end

  def edit?
    admin?
  end
end
