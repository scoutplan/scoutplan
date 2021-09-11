class UnitEventQuery
  attr_accessor :search_term
  attr_accessor :start_date

  def initialize(unit, membership)
    @unit = unit
    @membership = membership
    @start_date = Date.today
  end

  def execute
    scope = @unit.events
    # scope = scope.where(['starts_at >= ?', @start_date]) if @start_date.present?
    scope = scope.includes(:event_category, [event_rsvps: :user])
    scope = scope.where(status: :published) unless @membership.role == 'admin'
    scope.all
  end
end
