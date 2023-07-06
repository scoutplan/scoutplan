# frozen_string_literal: true

# attributes determining our ability to contact a user/member
module Contactable
  extend ActiveSupport::Concern

  def anonymous_email?
    contactable_object.email.match?(/anonymous-member-\h+@scoutplan.org/)
  end

  def emailable?
    ap self
    contactable_object.email.present? &&
      !contactable_object.anonymous_email? &&
      active
  end

  def smsable?
    contactable_object.phone.present?
  end

  def contactable?
    contactable_object.emailable?
  end

  private

  def active
    contactable_object.is_a?(UnitMembership) ? !contactable_object.status_inactive? : true
  end
end
