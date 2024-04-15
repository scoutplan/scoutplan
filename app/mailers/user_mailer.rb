# frozen_string_literal: true

# The Mailer class for sending email relating to specific events
#
class UserMailer < ApplicationMailer
  layout "user_mailer"

  def session_email
    @magic_link = params[:magic_link]
    @user = @magic_link.user
    @target_path = params[:target_path] || root_url
    mail(to:      email_address_with_name(@user.email, @user.full_display_name),
         from:    email_address_with_name("help@scoutplan.org", "Scoutplan"),
         subject: subject)
  end

  def new_user_email
    @code = params[:code]
    @email = params[:email]
    mail(to:      @email,
         from:    email_address_with_name("help@scoutplan.org", "Scoutplan"),
         subject: "Scoutplan verification code: #{@code}")
  end

  private

  def subject
    "Your Scoutplan sign-in link"
  end
end
