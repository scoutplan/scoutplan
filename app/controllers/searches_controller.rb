# frozen_string_literal: true

class SearchesController < UnitContextController
  SEARCH_LIMIT = 5

  layout "modal"

  def new; end

  def create
    @term = params[:query]
    return if @term.blank?

    find_events
    find_members
    find_locations
  end

  private

  def find_events
    event_policy = EventPolicy.new(current_member)
    @events = current_unit.events.where("title ILIKE ? OR short_description ILIKE ?", "%#{@term}%",
                                        "%#{@term}%").limit(SEARCH_LIMIT)
    @events = @events.select { |event| event_policy.show?(event) }
  end

  def find_members
    @members = current_unit.members.joins(:user).where("users.first_name ILIKE ? OR users.last_name ILIKE ?",
                                                       "%#{@term}%", "%#{@term}%").limit(SEARCH_LIMIT)
  end

  def find_locations
    return unless LocationPolicy.new(current_member, Location.new).index?

    @locations = current_unit.locations.where("name ILIKE ?", "%#{@term}%").limit(SEARCH_LIMIT)
  end
end
