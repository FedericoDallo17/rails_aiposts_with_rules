module Api
  module V1
    class UsersController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_user, only: [:show, :follow, :unfollow, :followers, :following]

      # GET /api/v1/users
      def index
        @users = User.all

        # Búsqueda simple
        if params[:q].present?
          query = "%#{params[:q]}%"
          @users = @users.where("username ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ?",
            query, query, query, query)
        end

        @pagy, @users = pagy(@users, items: params[:per_page] || 20)

        render json: {
          users: @users.map { |user| UserSerializer.new(user).as_json },
          pagination: pagy_metadata(@pagy)
        }
      end

      # GET /api/v1/users/:id
      def show
        render json: user_json(@user, detailed: true)
      end

      # POST /api/v1/users/:id/follow
      def follow
        follow = current_user.following_relationships.build(followed: @user)

        if follow.save
          render json: {
            message: "User followed successfully.",
            following: true,
            followers_count: @user.followers.count
          }
        else
          render json: {errors: follow.errors.full_messages}, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/users/:id/unfollow
      def unfollow
        follow = current_user.following_relationships.find_by(followed: @user)

        if follow&.destroy
          render json: {
            message: "User unfollowed successfully.",
            following: false,
            followers_count: @user.followers.count
          }
        else
          render json: {error: "Follow relationship not found."}, status: :not_found
        end
      end

      # GET /api/v1/users/:id/followers
      def followers
        @followers = @user.followers
        @pagy, @followers = pagy(@followers, items: params[:per_page] || 20)

        render json: {
          followers: @followers.map { |user| UserSerializer.new(user).as_json },
          pagination: pagy_metadata(@pagy)
        }
      end

      # GET /api/v1/users/:id/following
      def following
        @following = @user.following
        @pagy, @following = pagy(@following, items: params[:per_page] || 20)

        render json: {
          following: @following.map { |user| UserSerializer.new(user).as_json },
          pagination: pagy_metadata(@pagy)
        }
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def user_json(user, detailed: false)
        json = UserSerializer.new(user).as_json

        if detailed && current_user
          json[:following] = current_user.following?(user)
          json[:followed_by] = user.following?(current_user)
        end

        json
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

