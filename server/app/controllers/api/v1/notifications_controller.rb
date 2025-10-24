module Api
  module V1
    class NotificationsController < BaseController
      before_action :set_notification, only: [:show, :mark_as_read, :mark_as_unread]

      # GET /api/v1/notifications
      def index
        @notifications = current_user.notifications.includes(:notifiable).recent

        # Filter by status
        case params[:status]
        when "read"
          @notifications = @notifications.read
        when "unread"
          @notifications = @notifications.unread
        end

        @pagy, @notifications = pagy(@notifications, items: params[:per_page] || 20)

        render json: {
          notifications: @notifications.map { |notification| notification_json(notification) },
          pagination: pagy_metadata(@pagy),
          unread_count: current_user.notifications.unread.count
        }
      end

      # GET /api/v1/notifications/:id
      def show
        render json: notification_json(@notification)
      end

      # POST /api/v1/notifications/:id/mark_as_read
      def mark_as_read
        @notification.mark_as_read!
        render json: notification_json(@notification)
      end

      # POST /api/v1/notifications/:id/mark_as_unread
      def mark_as_unread
        @notification.mark_as_unread!
        render json: notification_json(@notification)
      end

      private

      def set_notification
        @notification = current_user.notifications.find(params[:id])
      end

      def notification_json(notification)
        {
          id: notification.id,
          event_type: notification.event_type,
          read_at: notification.read_at,
          created_at: notification.created_at,
          notifiable_type: notification.notifiable_type,
          notifiable_id: notification.notifiable_id,
          notifiable: notifiable_data(notification)
        }
      end

      def notifiable_data(notification)
        case notification.notifiable_type
        when "Post"
          post = notification.notifiable
          {
            id: post.id,
            content: post.content.truncate(100),
            user: UserSerializer.new(post.user).as_json
          }
        when "Comment"
          comment = notification.notifiable
          {
            id: comment.id,
            content: comment.content.truncate(100),
            user: UserSerializer.new(comment.user).as_json,
            post_id: comment.post_id
          }
        when "Like"
          like = notification.notifiable
          {
            id: like.id,
            user: UserSerializer.new(like.user).as_json,
            post_id: like.post_id
          }
        when "Follow"
          follow = notification.notifiable
          {
            id: follow.id,
            follower: UserSerializer.new(follow.follower).as_json
          }
        else
          nil
        end
      rescue
        nil
      end

      def pagy_metadata(pagy)
        {
          current_page: pagy.page,
          per_page: pagy.items,
          total_pages: pagy.pages,
          total_count: pagy.count
        }
      end
    end
  end
end

