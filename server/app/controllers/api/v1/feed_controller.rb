module Api
  module V1
    class FeedController < BaseController
      # GET /api/v1/feed
      def index
        # Get posts from users that current_user follows
        following_ids = current_user.following.pluck(:id)

        @posts = Post.includes(:user, :likers)
          .where(user_id: following_ids)
          .recent

        # Support for "load newer" posts by timestamp
        @posts = @posts.where("created_at > ?", Time.zone.parse(params[:since])) if params[:since].present?

        # Support for "load older" posts by timestamp
        @posts = @posts.where("created_at < ?", Time.zone.parse(params[:until])) if params[:until].present?

        @pagy, @posts = pagy(@posts, items: params[:per_page] || 20)

        render json: {
          posts: @posts.map { |post| post_json(post) },
          pagination: pagy_metadata(@pagy)
        }
      end

      private

      def post_json(post)
        {
          id: post.id,
          content: post.content,
          tags: post.tags,
          likes_count: post.likes_count,
          comments_count: post.comments_count,
          created_at: post.created_at,
          user: UserSerializer.new(post.user).as_json,
          liked_by_current_user: post.liked_by?(current_user)
        }
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

