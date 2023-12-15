class EventDashboard
  attr_reader :event, :accepted, :declined

  def initialize(event)
    @event = event
    @accepted = @event.rsvps.accepted
    @declined = @event.rsvps.declined
  end

  def accepted_adult_count
    @accepted_adult_count ||= accepted.adult.count
  end

  def accepted_youth_count
    @accepted_youth_count ||= accepted.youth.count
  end

  def accepted_count
    @accepted_count ||= accepted.count
  end

  def declined_count
    @declined_count ||= declined.count
  end

  def non_respondent_count
    @non_respondent_count ||= @event.non_respondents.count
  end

  def response_count
    @response_count ||= accepted_adult_count + accepted_youth_count + declined_count
  end

  def active_count
    @active_count ||= accepted_adult_count + accepted_youth_count + declined_count + non_respondent_count
  end

  def response_rate
    @response_rate ||= response_count / active_count.to_f
  end

  def non_invitee_count
    @non_invitee_count ||= @event.non_invitees.count
  end
end
