# frozen_string_literal: true

# abstract Mailer class that performs some basic housekeeping
class ScoutplanMailer < ApplicationMailer
  before_action :find_member
  before_action :find_unit
  # before_action :attach_logo

  # TODO: base64 encode image directly: https://stackoverflow.com/questions/16163353/display-base64-encoded-image-in-rails
  def attach_logo
    return unless @unit&.logo&.attached?

    attachments.inline["logo"] = @unit.logo.blob.download
  end

  def find_member
    @member = params[:member]
  end

  def find_unit
    @unit = @member.unit
  end
end
