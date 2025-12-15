module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [ :show, :update, :destroy, :followers, :following, :liked_posts, :commented_posts ]
      skip_before_action :authenticate_user!, only: [ :show ]

      def show
        render json: UserSerializer.new(@user).serializable_hash[:data][:attributes]
      end

      def update
        authorize_user!

        if @user.update(user_params)
          render json: {
            message: "User updated successfully",
            user: UserSerializer.new(@user).serializable_hash[:data][:attributes]
          }
        else
          render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize_user!
        @user.destroy
        render json: { message: "Account deleted successfully" }
      end

      def followers
        followers = @user.followers.page(params[:page]).per(params[:per_page] || 20)
        render json: {
          followers: followers.map { |u| UserSerializer.new(u).serializable_hash[:data][:attributes] },
          meta: pagination_meta(followers)
        }
      end

      def following
        following = @user.following.page(params[:page]).per(params[:per_page] || 20)
        render json: {
          following: following.map { |u| UserSerializer.new(u).serializable_hash[:data][:attributes] },
          meta: pagination_meta(following)
        }
      end

      def liked_posts
        posts = Post.joins(:likes).where(likes: { user_id: @user.id })
                    .distinct.page(params[:page]).per(params[:per_page] || 20)
        render json: {
          posts: posts.map { |p| PostSerializer.new(p, current_user).serializable_hash },
          meta: pagination_meta(posts)
        }
      end

      def commented_posts
        posts = Post.joins(:comments).where(comments: { user_id: @user.id })
                    .distinct.page(params[:page]).per(params[:per_page] || 20)
        render json: {
          posts: posts.map { |p| PostSerializer.new(p, current_user).serializable_hash },
          meta: pagination_meta(posts)
        }
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def authorize_user!
        unless current_user.id == @user.id
          render json: { error: "Unauthorized" }, status: :forbidden
        end
      end

      def user_params
        params.require(:user).permit(:email, :username, :first_name, :last_name, :bio, :website, :location, :profile_picture, :cover_picture, :password, :password_confirmation)
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
