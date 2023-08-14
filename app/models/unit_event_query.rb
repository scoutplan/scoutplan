# frozen_string_literal: true

# a query generator for Events, called from events#index
class UnitEventQuery
  attr_accessor :search_term, :start_date, :end_date

  def initialize(membership, unit = nil)
    @membership = membership
    @unit = unit || membership&.unit
  end

  def execute
    scope = @unit.events.includes(
      :event_category, :event_locations, :tags,
      [event_rsvps: :unit_membership]
    ).with_rich_text_description
    scope = scope.where(["ends_at >= ?", @start_date]) if @start_date.present?
    scope = scope.where(["starts_at <= ?", @end_date]) if @end_date.present?

    # limit non-admins to only published events
    scope = scope.where(status: :published) unless @membership&.admin?
    filter_by_tag(scope.all)
  end

  def filter_by_tag(scope)
    policy = EventPolicy.new(@membership, nil)
    scope.select do |event|
      policy.event = event
      policy.show?
    end
  end
end
