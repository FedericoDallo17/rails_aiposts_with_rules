module Api
  module V1
    class SearchController < BaseController
      skip_before_action :authenticate_user!

      def users
        query = params[:q]
        users = User.where("username ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR email ILIKE ? OR location ILIKE ?",
                          "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")
                    .page(params[:page]).per(params[:per_page] || 20)

        render json: {
          users: users.map { |u| UserSerializer.new(u).serializable_hash[:data][:attributes] },
          meta: pagination_meta(users)
        }
      end

      def posts
        query = params[:q]
        posts = Post.includes(:user, :comments, :likes, :reposts)

        # Search by content
        posts = posts.where("content ILIKE ?", "%#{query}%") if query.present?

        # Filter by user
        posts = posts.where(user_id: params[:user_id]) if params[:user_id].present?

        # Filter by tags
        if params[:tags].present?
          tags = params[:tags].is_a?(Array) ? params[:tags] : [ params[:tags] ]
          tags.each do |tag|
            posts = posts.where("tags::text ILIKE ?", "%#{tag}%")
          end
        end

        # Search in comments
        if params[:search_comments] == "true" && query.present?
          posts = posts.left_joins(:comments).where("posts.content ILIKE ? OR comments.content ILIKE ?", "%#{query}%", "%#{query}%").distinct
        end

        # Apply sorting
        posts = apply_sorting(posts)

        posts = posts.page(params[:page]).per(params[:per_page] || 20)

        render json: {
          posts: posts.map { |p| PostSerializer.new(p, current_user).serializable_hash },
          meta: pagination_meta(posts)
        }
      end

      private

      def apply_sorting(posts)
        case params[:sort_by]
        when "oldest"
          posts.oldest_first
        when "most_liked"
          posts.most_liked
        when "most_commented"
          posts.most_commented
        when "most_recently_liked"
          posts.left_joins(:likes).group("posts.id").order("MAX(likes.created_at) DESC NULLS LAST")
        when "most_recently_commented"
          posts.left_joins(:comments).group("posts.id").order("MAX(comments.created_at) DESC NULLS LAST")
        else # newest (default)
          posts.newest_first
        end
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
