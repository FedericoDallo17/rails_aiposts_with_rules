module Api
  module V1
    module Search
      class PostsController < BaseController
        skip_before_action :authenticate_user!, only: [:index]

        # GET /api/v1/search/posts?q=query&by=content&sort=recent
        def index
          if params[:q].blank?
            render json: {posts: [], pagination: {}}
            return
          end

          @posts = case params[:by]
          when "user"
            search_by_user
          when "tags"
            search_by_tags
          when "comments"
            search_by_comments
          else
            search_by_content
          end

          # Sorting
          @posts = apply_sorting(@posts)

          @pagy, @posts = pagy(@posts.includes(:user), items: params[:per_page] || 20)

          render json: {
            posts: @posts.map { |post| post_json(post) },
            pagination: pagy_metadata(@pagy)
          }
        end

        private

        def search_by_content
          Post.search_by_content(params[:q])
        end

        def search_by_user
          user_query = "%#{params[:q]}%"
          Post.joins(:user).where(
            "users.username ILIKE ? OR users.first_name ILIKE ? OR users.last_name ILIKE ?",
            user_query, user_query, user_query
          )
        end

        def search_by_tags
          tag = params[:q].gsub(/^#/, "").downcase
          Post.with_tag(tag)
        end

        def search_by_comments
          comment_query = "%#{params[:q]}%"
          Post.joins(:comments).where("comments.content ILIKE ?", comment_query).distinct
        end

        def apply_sorting(posts)
          case params[:sort]
          when "oldest"
            posts.oldest
          when "most_liked"
            posts.most_liked
          when "most_commented"
            posts.most_commented
          else
            posts.recent
          end
        end

        def post_json(post)
          {
            id: post.id,
            content: post.content,
            tags: post.tags,
            likes_count: post.likes_count,
            comments_count: post.comments_count,
            created_at: post.created_at,
            user: UserSerializer.new(post.user).as_json,
            liked_by_current_user: current_user ? post.liked_by?(current_user) : false
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
end

