module Api
  module V1
    class NotificationsController < BaseController
      before_action :set_notification, only: [ :mark_as_read, :mark_as_unread ]

      def index
        notifications = current_user.notifications.includes(:actor, :notifiable).newest_first
                                     .page(params[:page]).per(params[:per_page] || 20)
        render json: {
          notifications: notifications.map { |n| NotificationSerializer.new(n).serializable_hash },
          meta: pagination_meta(notifications)
        }
      end

      def mark_as_read
        @notification.mark_as_read!
        render json: { message: "Notification marked as read" }
      end

      def mark_as_unread
        @notification.mark_as_unread!
        render json: { message: "Notification marked as unread" }
      end

      private

      def set_notification
        @notification = current_user.notifications.find(params[:id])
      end

      def pagination_meta(collection)
        {
          current_page: collection.current_page,
          next_page: collection.next_page,
          prev_page: collection.prev_page,
          total_pages: collection.total_pages,
          total_count: collection.total_count
        }
      end
    end
  end
end
