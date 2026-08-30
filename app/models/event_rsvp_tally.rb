# frozen_string_literal: true

# Batch-loads the RSVP numbers the event-row dashboard tiles need.
#
# EventDashboard resolves those numbers per event, which costs six queries a row -- including
# Event#non_respondents, which loads the unit's whole active roster into Ruby to do an Array
# difference. That is fine on a single event page and ruinous on the agenda list, which renders
# every event in a ~20-month window. This computes the same figures for a whole collection in
# four queries, and #for returns an object that quacks like EventDashboard for the tile partial.
class EventRsvpTally
  Summary = Struct.new(:acceptance_count, :declines_count, :non_respondent_count) do
    def active_count
      acceptance_count + declines_count + non_respondent_count
    end

    def accept_rate
      rate(acceptance_count)
    end

    def decline_rate
      rate(declines_count)
    end

    def non_response_rate
      1 - accept_rate - decline_rate
    end

    private

    # EventDashboard divides straight through, so a unit with no active members renders NaN%.
    def rate(count)
      active_count.zero? ? 0.0 : count / active_count.to_f
    end
  end

  EMPTY = Summary.new(0, 0, 0).freeze

  def initialize(unit, events)
    @event_ids = Array(events).map(&:id)
    return if @event_ids.empty?

    @active_roster = unit.unit_memberships.status_active.count
    scope          = EventRsvp.where(event_id: @event_ids)

    @accepted  = scope.accepted_intent.group(:event_id).count
    @declined  = scope.declined_intent.group(:event_id).count

    # Responders limited to active members, mirroring Event#non_respondents, which subtracts the
    # event's responders from the active roster only.
    @responded = scope.joins(:unit_membership).merge(UnitMembership.status_active)
                      .distinct.group(:event_id).count(:unit_membership_id)
  end

  def for(event)
    return EMPTY if @event_ids.blank?

    Summary.new(
      @accepted[event.id]  || 0,
      @declined[event.id]  || 0,
      [@active_roster - (@responded[event.id] || 0), 0].max
    )
  end
end
