module Api
  module V1
    class FollowsController < BaseController
      def create
        user_to_follow = User.find(params[:id])
        follow = current_user.following_relationships.build(followed: user_to_follow)

        if follow.save
          create_follow_notification(follow)
          render json: { message: "Successfully followed #{user_to_follow.username}" }
        else
          render json: { errors: follow.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        user_to_unfollow = User.find(params[:id])
        follow = current_user.following_relationships.find_by(followed: user_to_unfollow)

        if follow
          follow.destroy
          render json: { message: "Successfully unfollowed #{user_to_unfollow.username}" }
        else
          render json: { error: "Not following this user" }, status: :not_found
        end
      end

      private

      def create_follow_notification(follow)
        Notification.create(
          user: follow.followed,
          actor: current_user,
          notifiable: follow,
          notification_type: "follow",
          message: "#{current_user.username} started following you"
        )
      end
    end
  end
end
