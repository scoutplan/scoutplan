# frozen_string_literal: true

# To deliver this notification:
#
# OverflowMailNotification.with(post: @post).deliver_later(current_user)
# OverflowMailNotification.with(post: @post).deliver(current_user)

class OverflowMailNotification < Noticed::Base
  deliver_by :database
  deliver_by :email, mailer: "OverflowMailer", if: :email_notifications?

  param :inbound_email
  param :unit

  # Define helper methods to make rendering easier.
  #
  # def message
  #   t(".message")
  # end
  #
  # def url
  #   post_path(params[:post])
  # end

  def email_notifications?
    recipient.emailable?
  end
end
