# frozen_string_literal: true

# a Texter subclass for sending SMS to existing members
class MemberTexter < ApplicationTexter
  attr_accessor :member

  def initialize(member)
    @member = member
    super
  end

  def magic_link_token
    member.magic_link.token if
    member.unit.settings(:security).enable_magic_links &&
    member.user.settings(:security).enable_magic_links
  end

  def to
    @member.phone
  end
end
