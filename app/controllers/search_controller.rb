# frozen_string_literal: true

# global search controller
class SearchController < UnitContextController
  layout false

  def results
    @term = params[:q]
    @events = @unit.events.where("title ILIKE ?", "%#{@term}%")
    @locations = @unit.locations.where("name ILIKE ?", "%#{@term}%")
    @members = @unit.members.joins(:user).where("users.first_name ILIKE ? OR users.last_name ILIKE ?", "%#{@term}%", "%#{@term}%")
  end
end
