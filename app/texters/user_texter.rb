# frozen_string_literal: true

# a Texter base class for sending SMS to Users
class UserTexter < ApplicationTexter
  attr_accessor :user

  def initialize(user)
    @user = user
    super(user)
  end

  def to
    user.phone
  end

  # used by superclass to composes the SMS. Here, we wrap it
  # in a time zone so the body has the right timestamps
  def body
    body_text
  end

  # override in subclasses. We could probably refactor
  # this to infer the correct template from the subclass
  # name, thus avoiding the need to override this method
  # in subclasses. Later.
  def body_text; end
end
