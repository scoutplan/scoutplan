# frozen_string_literal: true

# responsible for performing bulk user imports
class UnitMembershipsImportController < ApplicationController
  def new
    @current_unit = @unit = Unit.find(params[:unit_id])
  end

  def create
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_membership = @unit.membership_for(current_user)

    return unless @current_membership.admin?

    perform_import
    count = @memberships.count
  end

  def pundit_user
    @current_membership
  end

  private

  def perform_import
    @memberships = []
    file = params[:roster_file]
    data = SmarterCSV.process(file.tempfile)
    data.each do |row|
      user = User.invite!(email: row[:email], first_name: row[:first_name], last_name: row[:last_name])
      membership = @unit.memberships.create(user: user)
      @memberships << membership
    end
  end
end
