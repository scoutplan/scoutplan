# frozen_string_literal: true

# a query generator for Events, called from events#index
class UnitEventQuery
  attr_accessor :search_term, :start_date

  def initialize(membership, unit = nil)
    @membership = membership
    @unit = membership&.unit || unit
  end

  def execute
    scope = @unit.events.with_rich_text_description
    scope = scope.where(["starts_at >= ?", @start_date]) if @start_date.present?

    # limit non-admins to only published events
    scope = scope.where(status: :published) unless @membership&.admin?

    # all the left joins
    scope = scope.includes(:event_category, [event_rsvps: :unit_membership])
    scope.all
  end
end
