class NotificationsController < ApplicationController
  require_permission :can_subscribe_to_notifications?

  def index
  end

  def show
    @notification = current_user.notifications.find(params[:id])
  end

  def update
    @notification = current_user.notifications.find(params[:id])

    if params[:mark_read] == "true"
      @notification.update!(completed_at: Time.zone.now) unless @notification.read?
      redirect_to notifications_path, flash: { success: "Marked message as read" }
    elsif params[:mark_unread] == "true"
      @notification.update!(completed_at: nil) unless @notification.unread?
      redirect_to notifications_path, flash: { success: "Marked message as unread" }
    else
      raise "Update method undefined!"
    end
  end
end
