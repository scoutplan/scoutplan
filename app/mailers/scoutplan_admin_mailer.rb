# frozen_string_literal: true

# mailer for admins of the Scoutplan app (not unit admins)
class ScoutplanAdminMailer < ApplicationMailer
  def mail_failure_email
    @from_address = params[:from_address]
    @to_address = params[:to_address]
    @message_id = params[:message_id]
    ENV["SCOUTPLAN_ADMINS"].split(",").each do |email|
      mail(to: email, subject: "Scoutplan email failure")
    end
  end
end

