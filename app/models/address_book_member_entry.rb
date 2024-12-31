# frozen_string_literal: true

class AddressBookMemberEntry < AddressBookEntry
  attr_accessor :member

  def initialize(member)
    @member = member
    super()
  end

  def key
    "membership_#{member.id}"
  end

  def name
    member.display_name
  end

  def description
    return "No contact methods available" unless member.contactable?

    contact_methods = []
    contact_methods << "<span><i class='fa-envelope fa-solid'></i>&nbsp;Email</span>" if member.emailable?
    contact_methods << "<span><i class='fa-message-sms fa-solid'></i>&nbsp;Text message</span>" if member.smsable?
    contact_methods.join.html_safe
  end

  def contactable_status
    member.contactable? ? "contactable" : "not-contactable"
  end
end
