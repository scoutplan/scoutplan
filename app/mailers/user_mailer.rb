# frozen_string_literal: true

# The Mailer class for sending email relating to specific events
#
class UserMailer < ApplicationMailer
  helper MagicLinksHelper

  def session_email
    @magic_link = params[:magic_link]
    @user = @magic_link.user
    @unit = @magic_link.unit
    @target_path = params[:target_path] || root_url
    mail(to: email_address_with_name(@user.email, @user.full_display_name),
         from: email_address_with_name("help@scoutplan.org", "Scoutplan"),
         subject: "Sign in to Scoutplan")
  end
end
