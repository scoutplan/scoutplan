# frozen_string_literal: true

class UnitContextController < ApplicationController
  before_action :find_unit_info, only: %i[index new create]
  before_action :track_activity

  def current_unit
    Unit.first
  end

  attr_reader :current_membership

  def pundit_user
    @membership
  end

  private

  def find_unit_info
    # TODO: scope this to the current user's memberships
    @current_unit = @unit = Unit.includes(:unit_memberships).find(params[:unit_id])
    @current_member = @membership = @unit.membership_for(current_user)
  end
end
