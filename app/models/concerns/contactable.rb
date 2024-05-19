module Contactable
  extend ActiveSupport::Concern

  REGEXP_ANONYMOUS = /anonymous-member-\h+@scoutplan.org/

  def anonymous_email?
    contactable_object.email.match?(REGEXP_ANONYMOUS)
  end

  def contactable?(via: :any)
    return contactable_object.emailable? if via == :email
    return contactable_object.smsable? if via == :sms
    return contactable_object.emailable? && contactable_object.smsable? if via == :any

    false
  end

  def contact_preference?(via: :email)
    return settings(:communication).via_email == "true" || settings(:communication).via_email if via == :email
    return settings(:communication).via_sms == "true" || settings(:communication).via_sms if via == :sms

    false
  end

  def emailable?
    contactable_object.email.present? &&
      !contactable_object.anonymous_email? &&
      active
  end

  def smsable?
    contactable_object.phone.present?
  end

  private

  def active
    contactable_object.is_a?(UnitMembership) ? !contactable_object.status_inactive? : true
  end
end
