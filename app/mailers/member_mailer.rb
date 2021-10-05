# frozen_string_literal: true

# mailer for sending Member communications
class MemberMailer < ApplicationMailer
  def invitation_email
    @member = params[:member]
    mail(to: email_address_with_name(@user.email, @user.display_full_name),
         from: email_address_with_name(@unit.settings(:communication).from_email, @unit.name),
         subject: "#{@unit.name} Event Invitation: #{@event.title}")
  end

  def digest_email
    @member  = params[:member]
    @user    = @member.user
    @unit    = @member.unit
    @events  = @unit.events.published.future.upcoming
    # mail(to: email_address_with_name(@user.email, @user.display_full_name),
         # from: email_address_with_name(@unit.settings(:communication).from_email, @unit.name),
         # subject: "#{@unit.name} Digest")

ap "#{ @user.display_full_name } <#{ @user.email }>"

    mail(to: "#{ @user.display_full_name } <#{ @user.email }>",
         from: email_address_with_name(@unit.settings(:communication).from_email, @unit.name),
         subject: "#{@unit.name} Digest")
  end
end
