# frozen_string_literal: true

# a Texter base class for sending SMS to existing members
class MemberTexter < ApplicationTexter
  attr_accessor :member

  def initialize(member)
    @member = member
    super
  end

  def to
    @member.phone
  end

  def send_message
    super
    Tracker.new(@member).track_activity(
      "send_sms",
      { "type" => self.class.name }
    )
  end

  def renderer
    ApplicationController.renderer.new(
      http_host: ENV["SCOUTPLAN_HOST"],
      https: ENV["SCOUTPLAN_PROTOCOL"] == "https"
    )
  end

  # used by superclass to composes the SMS. Here, we wrap it
  # in a time zone so the body has the right timestamps
  def body
    Time.use_zone(@member.unit.time_zone) do
      body_text
    end
  end

  # override in subclasses. We could probably refactor
  # this to infer the correct template from the subclass
  # name, thus avoiding the need to override this method
  # in subclasses. Later.
  def body_text; end
end
