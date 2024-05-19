# frozen_string_literal: true

class UnitMembershipsImportController < UnitContextController
  def new
    @unit = Unit.find(params[:unit_id])
    authorize :unit_membership_import, :new?
    page_title @current_unit.name, "Import Members"
  end

  def create
    @unit = Unit.find(params[:unit_id])
    current_member = @current_unit.membership_for(current_user)
    return unless current_member.admin?

    file = params[:roster_file]
    results = CsvMemberImporter.perform_import(file, @unit)
    @new_memberships = results[:new_memberships]
    @existing_memberships = results[:existing_memberships]
  end

  def pundit_user
    current_member
  end
end
