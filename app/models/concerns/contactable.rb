# frozen_string_literal: true

# attributes determining our ability to contact a user/member
module Contactable
  extend ActiveSupport::Concern

  def anonymous_email?
    contactable_object.email.match?(/anonymous-member-\h+@scoutplan.org/)
  end

  def emailable?
    contactable_object.email.present? && !contactable_object.anonymous_email?
  end

  def smsable?
    contactable_object.phone.present?
  end

  def contactable?
    contactable_object.emailable?
  end
end
