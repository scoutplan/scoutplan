# frozen_string_literal: true

# To deliver this notification:
#
# OverflowMailNotification.with(post: @post).deliver_later(current_user)
# OverflowMailNotification.with(post: @post).deliver(current_user)

class OverflowMailNotification < Noticed::Base
  deliver_by :database
  deliver_by :email, mailer: "OverflowMailer"

  param :inbound_email
  param :unit
end
