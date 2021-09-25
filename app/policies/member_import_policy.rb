class MemberImportPolicy < UnitContextPolicy
  def create?
    admin?
  end
end
