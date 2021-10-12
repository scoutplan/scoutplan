# frozen_string_literal: true

# mailer for sending Member communications
class MemberMailer < ApplicationMailer
  before_action :find_member
  before_action :find_user
  before_action :find_unit

  def invitation_email
    mail(to: email_address_with_name(@user.email, @user.display_full_name),
         from: email_address_with_name(@unit.settings(:communication).from_email, @unit.name),
         subject: "#{@unit.name} Event Invitation: #{@event.title}")
  end

  def digest_email
    @events  = @unit.events.published.future.upcoming
    mail(to: email_address_with_name(@user.email, @user.display_full_name),
         from: email_address_with_name(@unit.settings(:communication).from_email, @unit.name),
         subject: "#{@unit.name} Digest")
  end

  def daily_reminder_email
    @events = @unit.events.published.today
    mail(to: email_address_with_name(@user.email, @user.display_full_name),
         from: email_address_with_name(@unit.settings(:communication).from_email, @unit.name),
         subject: daily_reminder_subject)
  end

  private

  def daily_reminder_subject
    "#{@unit.name} — " + ((@events.count == 1) ? @events.first.title : "Today's Events")
  end

  def find_member
    @member = params[:member]
  end

  def find_user
    @user = @member.user
  end

  def find_unit
    @unit = @member.unit
  end
end
