# frozen_string_literal: true

# abstract Mailer class that performs some basic housekeeping
class ScoutplanMailer < ApplicationMailer
  has_history
  before_action :find_member
  before_action :find_unit

  # base64 encode image directly: https://stackoverflow.com/questions/16163353/display-base64-encoded-image-in-rails
  def attach_logo
    return unless @unit&.logo&.attached?

    attachments.inline["logo"] = @unit.logo.blob.download
  end

  def find_member
    @member = params[:member]
  end

  def find_unit
    @unit = @member&.unit
  end

  def unit_from_address_with_name(person_name = nil)
    return unless @unit

    name = @unit.name
    name = "#{person_name} at #{name}" if person_name
    email_address_with_name(@unit.from_address, name)
  end

  # given a string, prepends with the unit name
  # "Test Subject" => "Troop 123 - Test Subject"
  def annotated_subject(subject)
    [@unit&.name, subject].join(" - ")
  end
end
