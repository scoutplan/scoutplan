class UnitContextController < ApplicationController
  before_action :find_user, :find_unit, :find_membership

  def current_unit
    Unit.first
  end

  def pundit_user
    @membership
  end

private

  # override this in subclasses as needed
  def find_user
    @user = current_user
  end

  def find_unit
    # TODO: scope this to the current user's memberships
    @unit = Unit.includes(:unit_memberships).find(params[:unit_id])
  end

  def find_membership
    @membership = @unit.membership_for(current_user)
  end
end
