# frozen_string_literal: true

# a query generator for Events, called from events#index
class UnitEventQuery
  attr_accessor :search_term, :start_date

  def initialize(membership, unit = nil)
    @membership = membership
    @unit = unit || membership&.unit
  end

  def execute
    scope = @unit.events.preload(:event_category, [event_rsvps: :unit_membership]).with_rich_text_description
    scope = scope.where(["starts_at >= ?", @start_date]) if @start_date.present?

    # limit non-admins to only published events
    scope = scope.where(status: :published) unless @membership&.admin?

    # all the left joins
    # scope = scope.includes(:event_category, [event_rsvps: :unit_membership])
    scope.all
  end

  def execute_grouped
    scope = @unit.events.includes(:event_category, [event_rsvps: :unit_membership]).order(:starts_at)
                 .with_rich_text_description.group_by { |e| e.starts_at.beginning_of_month }
    scope = scope.where(["starts_at >= ?", @start_date]) if @start_date.present?
    scope = scope.where(status: :published) unless @membership&.admin?
    scope.all
  end
end
