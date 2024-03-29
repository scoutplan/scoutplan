# frozen_string_literal: true

# Policy class governing Payments and what members can do with them
class PaymentPolicy < UnitContextPolicy
  def initialize(membership, payment)
    super
    @membership = membership
    @payment = payment
  end

  def index?
    admin?
  end

  def create?
    admin?
  end

  def destroy?
    admin?
  end

  def new?
    return true if admin?
    
    Flipper.enabled?(:payments, @membership.unit) && Flipper.enabled?(:payments, @membership)
  end

  def receive?
    admin?
  end
end
