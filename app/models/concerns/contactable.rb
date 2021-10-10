module Contactable
  extend ActiveSupport::Concern

  def anonymous_email?
    contactable_object.email.match?(/anonymous-member-\h+@scoutplan.org/)
  end

  def emailable?
    !contactable_object.anonymous_email?
  end

  def contactable?
    contactable_object.emailable?
  end
end
