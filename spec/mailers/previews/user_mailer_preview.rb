# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/event

require "faker"
require "factory_bot"

class UserMailerPreview < ActionMailer::Preview
  def session_email
    unit = Unit.first
    member = unit.members.first
    user = member.user
    UserMailer.with(user: user, unit: unit, target_path: "/").session_email
  end
end
