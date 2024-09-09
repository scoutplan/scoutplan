# frozen_string_literal: true

class SearchesController < UnitContextController
  SEARCH_LIMIT = 5

  layout "modal"

  def new; end

  def create
    @term = params[:query]
    return if @term.blank?

    @events = current_unit.events.where("title ILIKE ?", "%#{@term}%").limit(SEARCH_LIMIT)
    @members = current_unit.members.joins(:user).where("users.first_name ILIKE ? OR users.last_name ILIKE ?",
                                                       "%#{@term}%", "%#{@term}%").limit(SEARCH_LIMIT)
    @locations = current_unit.locations.where("name ILIKE ?", "%#{@term}%").limit(SEARCH_LIMIT)
  end
end
