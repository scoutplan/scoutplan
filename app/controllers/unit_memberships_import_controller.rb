# frozen_string_literal: true

# responsible for performing bulk user imports
class UnitMembershipsImportController < ApplicationController
  def new
    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
    authorize :member_import, :create?
    page_title @unit.name, "Import Members"
  end

  def create

    ap params

    @current_unit = @unit = Unit.find(params[:unit_id])
    @current_member = @unit.membership_for(current_user)
    return unless @current_member.admin?

    file = params[:roster_file]
    results = CsvMemberImporter.perform_import(file, @unit)
    @new_memberships = results[:new_memberships]
    @existing_memberships = results[:existing_memberships]
  end

  def pundit_user
    @current_member
  end
end
