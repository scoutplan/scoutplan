class EventDashboard
  attr_reader :event

  ORDER_CLAUSE = "users.last_name, users.first_name".freeze

  def initialize(event)
    @event = event
  end

  def acceptances
    @acceptances ||= @event.event_rsvps.includes(unit_membership: [:user, :parents,
                                                                   :children]).accepted_intent.order(ORDER_CLAUSE)
  end

  def declines
    @declines ||= @event.event_rsvps.includes(unit_membership: [:user, :parents,
                                                                :children]).declined_intent.order(ORDER_CLAUSE)
  end

  def accepted_adult_count
    @accepted_adult_count ||= acceptances.adult.count
  end

  def accepted_youth_count
    @accepted_youth_count ||= acceptances.youth.count
  end

  def acceptance_count
    @acceptance_count ||= acceptances.count
  end

  def declines_count
    @declines_count ||= declines.count
  end

  def non_respondent_count
    @non_respondent_count ||= @event.non_respondents.count
  end

  def response_count
    @response_count ||= accepted_adult_count + accepted_youth_count + declines_count
  end

  def membership_count
    @membership_count ||= accepted_adult_count + accepted_youth_count + declines_count + non_respondent_count
  end

  def response_rate
    @response_rate ||= decline_rate + accept_rate
  end

  def non_response_rate
    @non_response_rate ||= active_count.zero? ? 0 : 1 - response_rate
  end

  def decline_rate
    @decline_rate ||= active_count.zero? ? 0 : declines_count / active_count.to_f
  end

  def accept_rate
    @accept_rate ||= active_count.zero? ? 0 : acceptance_count / active_count.to_f
  end

  def non_invitee_count
    @non_invitee_count ||= @event.non_invitees.count
  end

  def active_count
    @active_count ||= accepted_adult_count + accepted_youth_count + declines_count + non_respondent_count
  end
end
