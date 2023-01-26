# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/event

require "faker"
require "factory_bot"

class UserMailerPreview < ActionMailer::Preview
  def session_email
    unit = Unit.first
    member = unit.members.first

    magic_link = MagicLink.generate_link(member, "/")

    UserMailer.with(magic_link: magic_link).session_email
  end
end
