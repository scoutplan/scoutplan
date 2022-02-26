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
end
