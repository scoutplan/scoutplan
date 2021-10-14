# frozen_string_literal: true

# mailer for sending Member communications
class MemberMailer < ScoutplanMailer
  before_action :find_user
  before_action :set_addresses
  before_action :time_zone

  def invitation_email
    mail(to: @to_address,
         from: @from_address,
         subject: "#{@unit.name} Event Invitation: #{@event.title}")
  end

  def digest_email
    @this_week_events = @unit.events.published.this_week
    @upcoming_events = @unit.events.published.upcoming
    mail(to: @to_address,
         from: @from_address,
         subject: "#{@unit.name} Digest")
  end

  def daily_reminder_email
    @events = @unit.events.published.today
    mail(to: @to_address,
         from: @from_address,
         subject: daily_reminder_subject)
  end

  private

  def set_addresses
    @to_address = email_address_with_name(@user.email, @user.display_full_name)
    @from_address = email_address_with_name(@unit.settings(:communication).from_email, @unit.name)
  end

  def daily_reminder_subject
    "#{@unit.name} — " + (@events.count == 1 ? @events.first.title : "Today's Events")
  end

  def find_member
    @member = params[:member]
  end

  def find_user
    @user = @member.user
  end

  def time_zone
    Time.zone = @unit.settings(:locale).time_zone
  end
end
