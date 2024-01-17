class RsvpNagMailer < ApplicationMailer
  helper ApplicationHelper
  helper MagicLinksHelper
  layout "basic_mailer"

  attr_reader :recipient, :event, :unit

  before_action :setup

  def rsvp_nag_notification
    puts @event
    mail(to: to_address, from: from_address, subject: subject)
  end

  private

  def setup
    @recipient = params[:recipient]
    @event = params[:event]
    @unit = @event.unit
  end

  def subject
    "[#{unit.name}] Are you going to the #{event.title}?"
  end

  def to_address
    email_address_with_name(recipient.email, recipient.display_name)
  end

  def from_address
    email_address_with_name(unit.from_address, unit.name)
  end
end
