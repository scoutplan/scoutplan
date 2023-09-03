# frozen_string_literal: true

module UnitMembership::EventInvitable
  extend ActiveSupport::Concern

  RUNS_AT_HOUR = 10

  included do
    after_commit :enqueue_event_invitation_job!, on: [:create, :update]
  end

  def receives_event_invitations?
    settings(:communication).receives_event_invitations
  end

  def next_event_invitation_runs_at
    Date.tomorrow.in_time_zone.change(hour: RUNS_AT_HOUR, min: 0, sec: 0)
  end

  def enqueue_event_invitation_job!(when_to_run = :now)
    return unless receives_event_invitations?

    wait_until = when_to_run == :now ? 1.minute.from_now : next_event_invitation_runs_at
    EventInvitationJob.set(wait_until: wait_until).perform_later(self)
  end
end
