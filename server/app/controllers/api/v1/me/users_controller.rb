module Api
  module V1
    module Me
      class UsersController < BaseController
        # GET /api/v1/me
        def show
          render json: UserSerializer.new(current_user).as_json
        end

        # PUT /api/v1/me
        def update
          if current_user.update(user_params)
            render json: UserSerializer.new(current_user).as_json
          else
            render json: {errors: current_user.errors.full_messages}, status: :unprocessable_entity
          end
        end

        # GET /api/v1/me/likes
        def likes
          @posts = current_user.liked_posts.includes(:user).recent
          @pagy, @posts = pagy(@posts, items: params[:per_page] || 20)

          render json: {
            posts: @posts.map { |post| post_json(post) },
            pagination: pagy_metadata(@pagy)
          }
        end

        # GET /api/v1/me/comments
        def comments
          @posts = Post.includes(:user)
            .joins(:comments)
            .where(comments: {user_id: current_user.id})
            .distinct
            .recent

          @pagy, @posts = pagy(@posts, items: params[:per_page] || 20)

          render json: {
            posts: @posts.map { |post| post_json(post) },
            pagination: pagy_metadata(@pagy)
          }
        end

        # GET /api/v1/me/mentions
        def mentions
          @posts = Post.includes(:user)
            .where("content ILIKE ?", "%@#{current_user.username}%")
            .recent

          @pagy, @posts = pagy(@posts, items: params[:per_page] || 20)

          render json: {
            posts: @posts.map { |post| post_json(post) },
            pagination: pagy_metadata(@pagy)
          }
        end

        # GET /api/v1/me/tagged
        def tagged
          # Posts que tienen tags en los que el usuario está mencionado
          # Esto es una interpretación, puede ajustarse según necesidad
          tags = ["##{current_user.username.downcase}"]
          @posts = Post.includes(:user)
            .where("tags && ARRAY[?]::varchar[]", tags)
            .recent

          @pagy, @posts = pagy(@posts, items: params[:per_page] || 20)

          render json: {
            posts: @posts.map { |post| post_json(post) },
            pagination: pagy_metadata(@pagy)
          }
        end

        private

        def user_params
          params.require(:user).permit(:first_name, :last_name, :bio, :website, :location, :profile_picture, :cover_picture)
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
end

