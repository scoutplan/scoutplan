# frozen_string_literal: true

# a query generator for Events, called from events#index
class UnitEventQuery
  attr_accessor :search_term, :start_date

  def initialize(unit, membership)
    @unit = unit
    @membership = membership
  end

  def execute
    scope = @unit.events.with_rich_text_description
    scope = scope.where(['starts_at >= ?', @start_date]) if @start_date.present?
    scope = scope.where(status: :published) unless @membership.role == 'admin'
    scope = scope.includes(:event_category, [event_rsvps: :unit_membership])
    scope.all
  end
end
