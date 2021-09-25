# frozen_string_literal: true

class UnitEventQuery
  attr_accessor :search_term, :start_date

  def initialize(unit, membership)
    @unit = unit
    @membership = membership
  end

  def execute
    scope = @unit.events
    scope = scope.where(['starts_at >= ?', @start_date]) if @start_date.present?
    scope = scope.where(status: :published) unless @membership.role == 'admin'
    # scope = scope.includes(:event_category, [event_rsvps: :user])
    scope.all
  end
end
