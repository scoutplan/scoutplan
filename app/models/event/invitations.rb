# frozen_string_literal: true

module Event::Invitations
  extend ActiveSupport::Concern

  DEFAULT_INVITATION_LEAD_TIME = 14.days.freeze

  included do
    has_many :event_invitations
  end

  # invite a member to this event
  def invite!(member)
    return unless member.present?

    EventInvitationMailer.with(event_id: id, member: member).event_invitation_email.deliver_later
  end

  # when should we send the invitation?
  def invite_at(member)
    (starts_at - invitation_lead_time(member)).beginning_of_day
  end

  # has this member been invited?
  def invited?(member)
    event_invitations.exists?(unit_membership: member)
  end

  # should we invite this member now?
  def should_invite?(member)
    invite_at(member).past? && !invited?(member)
  end

  # how long before the event should we send the invitation?
  def invitation_lead_time(member)
    return 0 if member.nil?

    DEFAULT_INVITATION_LEAD_TIME
  end
end
