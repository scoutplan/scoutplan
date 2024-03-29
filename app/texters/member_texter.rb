# frozen_string_literal: true

# a Texter base class for sending SMS to existing members
class MemberTexter < ApplicationTexter
  attr_accessor :member, :unit

  def initialize(member)
    @member = member
    @unit = @member.unit
    super
  end

  def to
    @member.phone
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
