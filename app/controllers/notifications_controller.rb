class NotificationsController < UnitContextController
  before_action :find_notifications, only: [:index]

  def index; end

  def mark_all_as_read
    current_member.notifications.mark_as_read
    find_notifications
  end

  def mark_all_as_unread
    current_member.notifications.mark_as_unread
    find_notifications
  end

  def mark_as_read
    find_notification
    @notification.mark_as_read
  end

  def mark_as_unread
    find_notification
    @notification.mark_as_read
  end

  private

  def find_notification
    @notification = current_member.notifications.find(params[:id])
  end

  def find_notifications
    @notifications = current_member.notifications.order(created_at: :desc)
  end
end
