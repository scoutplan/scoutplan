class EventRsvpMailer < ApplicationMailer
  MAP_ATTACHMENT_NAME = "map.png".freeze

  layout "basic_mailer"

  helper GrammarHelper, MagicLinksHelper, EventsHelper, ApplicationHelper

  before_action :setup

  def event_rsvp_notification
    attach_files
    @presenter = RsvpMailPresenter::Factory.build(@rsvp, @recipient)
    mail(to:       @presenter.to_address,
         from:     @presenter.from_address,
         reply_to: @presenter.reply_to,
         subject:  @presenter.subject)
  end

  private

  def attach_files
    attachments[@event.ical_filename] = IcalExporter.ics_attachment(@event, @rsvp.member)
    attachments[MAP_ATTACHMENT_NAME] = @event.static_map.blob.download if @event.static_map.attached?
  end

  def setup
    @rsvp, @recipient = params[:event_rsvp], params[:recipient]
    @event = @rsvp.event
    @unit = @rsvp.unit
  end
end

module RsvpMailPresenter
  # rubocop:disable Layout/LineLength
  class Factory
    def self.build(rsvp, recipient)
      return RsvpApproverActionRequiredMailPresenter.new(rsvp, recipient) if rsvp.requires_approval? && EventRsvpPolicy.new(recipient, rsvp).approve?
      return RsvpApprovalPendingMailPresenter.new(rsvp, recipient) if rsvp.requires_approval?

      RsvpReceivedMailPresenter.new(rsvp, recipient)
    end
  end
  # rubocop:enable Layout/LineLength

  class RsvpBaseMailPresenter
    attr_reader :rsvp, :recipient, :event, :unit

    def initialize(rsvp, recipient)
      @rsvp, @recipient = rsvp, recipient
      @event = @rsvp.event
      @unit = @rsvp.unit
    end

    def subject
      raise NotImplementedError
    end

    def to_address
      ApplicationMailer.email_address_with_name(recipient.email, recipient.full_display_name)
    end

    def from_address
      ApplicationMailer.email_address_with_name(unit.from_address, unit.name)
    end

    def reply_to
      rsvp.reply_to
    end
  end

  class RsvpReceivedMailPresenter < RsvpBaseMailPresenter
    def subject
      "[#{unit.name}] Your RSVP for #{event.title} has been received"
    end
  end

  class RsvpApprovalPendingMailPresenter < RsvpBaseMailPresenter
    def subject
      "[#{unit.name}] Your RSVP to the #{event.title} is pending approval"
    end
  end

  class RsvpApproverActionRequiredMailPresenter < RsvpBaseMailPresenter
    def subject
      "[#{unit.name}] Action required: approve #{rsvp.member.first_name}'s RSVP to the #{event.title}"
    end
  end
end
