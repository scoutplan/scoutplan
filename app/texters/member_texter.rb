# frozen_string_literal: true

# a Texter subclass for sending SMS to existing members
class MemberTexter < ApplicationTexter
  attr_accessor :member

  def initialize(member)
    @member = member
    super
  end

  def to
    @member.phone
  end
end
