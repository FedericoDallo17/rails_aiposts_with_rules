module Api
  module V1
    class FeedController < BaseController
      def index
        # Get posts from followed users
        followed_user_ids = current_user.following.pluck(:id)
        posts = Post.where(user_id: followed_user_ids)
                    .or(Post.where(id: Repost.where(user_id: followed_user_ids).select(:post_id)))
                    .includes(:user, :likes, :comments, :reposts)
                    .newest_first
                    .page(params[:page]).per(params[:per_page] || 20)

        # Also include reposts metadata
        repost_data = Repost.where(user_id: followed_user_ids, post_id: posts.pluck(:id))
                            .includes(:user)

        render json: {
          feed: posts.map do |post|
            reposted_by = repost_data.select { |r| r.post_id == post.id }.map do |r|
              { username: r.user.username, created_at: r.created_at }
            end
            PostSerializer.new(post, current_user).serializable_hash.merge(reposted_by: reposted_by)
          end,
          meta: pagination_meta(posts)
        }
      end

      private

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
