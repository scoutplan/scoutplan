class OrganizerPrepMailer < ApplicationMailer
  layout "basic_mailer"

  helper ApplicationHelper

  attr_reader :recipient, :event, :unit

  before_action :setup

  def organizer_prep_notification
    mail(to: to_address, from: from_address, subject: subject)
  end

  private

  def setup
    @recipient = params[:recipient]
    @event = params[:event]
    @unit = @event.unit
  end

  def subject
    "[#{unit.name}] Time to get ready for the #{event.title} event on #{event.starts_at.strftime('%B %-d')}"
  end

  def to_address
    email_address_with_name(recipient.email, recipient.display_name)
  end

  def from_address
    email_address_with_name(unit.from_address, unit.name)
  end
end
