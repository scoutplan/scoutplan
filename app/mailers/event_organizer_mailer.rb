class EventOrganizerMailer < ScoutplanMailer
  layout "basic_mailer"

  def assignment_email
    setup
    mail(to: @user.email, from: unit_from_address_with_name, reply_to: @event.email, subject: subject)
  end

  private

  def setup
    @recipient = params[:recipient]
    @event_organizer = params[:event_organizer]
    @event  = @event_organizer.event
    current_unit   = @event.unit
    @member = @event_organizer.unit_membership
    @user   = @member.user
  end

  def subject
    "[#{current_unit.name}] You've been added as an organizer for #{@event.title}"
  end
end
