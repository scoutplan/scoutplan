# frozen_string_literal: true

# To deliver this notification:
#
# EventReminderNotification.with(event: @event).deliver_later(@event.attendees)

class EventReminderNotification < Noticed::Base
  # Add your delivery methods
  #
  deliver_by :database
  deliver_by :email, mailer: "EventReminderMailer", if: :emailable?
  # deliver_by :slack
  # deliver_by :custom, class: "MyDeliveryMethod"

  # Add required params
  #
  # param :post

  param :event

  # Define helper methods to make rendering easier.
  #
  # def message
  #   t(".message")
  # end
  #
  # def url
  #   post_path(params[:post])
  # end

  def emailable?
    recipient.emailable? && recipient.unit.settings(:communication).daily_reminder == "yes"
  end
end
