class UnitContextController < ApplicationController
  before_action :find_unit_info, only: [:index, :new, :create]

  def current_unit
    Unit.first
  end

  def pundit_user
    @membership
  end

private

  def find_unit_info
    # TODO: scope this to the current user's memberships
    @current_unit = Unit.includes(:unit_memberships).find(params[:unit_id])
    @membership = @unit.membership_for(current_user)
  end
end
