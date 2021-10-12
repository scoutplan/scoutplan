# frozen_string_literal: true

# notify members
class MemberNotifier
  # invite a user to a unit through a UnitMembership (aka member)
  def self.invite_member_to_unit(member)
    @magic_link_token = member.magic_link.token if
      @unit.settings(:security).enable_magic_links &&
      @user.settings(:security).enable_magic_links
    MemberMailer.with(member: member).invitation_email.deliver_later
  end

  def self.send_digest(member)
    return unless member.contactable?

    MemberMailer.with(member: member).digest_email.deliver_later
  end

  def self.send_daily_reminder(member)
    @magic_link_token = member.magic_link.token if
      @unit.settings(:security).enable_magic_links &&
      @user.settings(:security).enable_magic_links
    MemberMailer.with(member: member).daily_reminder_email.deliver_later
  end
end
