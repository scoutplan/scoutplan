# frozen_string_literal: true

# global search controller
class SearchController < UnitContextController
  layout false

  def results
    @term = params[:q]
    event_scope = current_unit.events.where("title ILIKE ?", "%#{@term}%")
    event_scope = event_scope.where(status: :published) unless @membership&.admin?
    @events = event_scope.all
    @locations = current_unit.locations.where("name ILIKE ?", "%#{@term}%") if policy(:location).index?
    @members = current_unit.members.joins(:user).where("users.first_name ILIKE ? OR users.last_name ILIKE ?", "%#{@term}%", "%#{@term}%") if policy(:unit_membership).index?
  end
end
