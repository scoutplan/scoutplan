# frozen_string_literal: true

# The Mailer class for sending email relating to specific events
#
class UserMailer < ApplicationMailer
  helper MagicLinksHelper

  def session_email
    @user = params[:user]
    @unit = params[:unit] || @user.units.first
    @member = @unit&.membership_for(@user)
    @target_path = params[:target_path] || root_url
    mail(to: email_address_with_name(@user.email, @user.full_display_name),
         from: email_address_with_name("help@scoutplan.org", "Scoutplan"),
         subject: "Sign in to Scoutplan")
  end
end
