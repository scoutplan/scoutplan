class EventRsvpOrganizerMailer < ApplicationMailer
  attr_reader :event, :recipient, :start_date, :unit

  before_action :setup

  layout "basic_mailer"

  helper MagicLinksHelper

  def event_rsvp_organizer_notification
    ap "HERE!!!!!"
    mail(to:       to_address,
         from:     from_address,
         reply_to: reply_to,
         subject:  subject)
  end

  private

  def setup
    @event = params[:event]
    @recipient = params[:recipient]
    @unit = @event.unit
    @dashboard = EventDashboard.new(@event)
    @event_rsvp_groups = @event.event_rsvps
                               .joins(unit_membership: :user)
                               .order("users.last_name, users.first_name")
                               .group_by(&:response)
                               .slice("accepted", "accepted_pending", "declined", "declined_pending")
  end

  ### Mail helpers
  def from_address
    email_address_with_name(@unit.from_address, @unit.name)
  end

  def to_address
    email_address_with_name(@recipient.email, @recipient.display_name)
  end

  def reply_to
    email_address_with_name(@unit.from_address, @unit.name)
  end

  def subject
    "[#{unit.name}] You have new RSVPs for #{event.title}"
  end
end
