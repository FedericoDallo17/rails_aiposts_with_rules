module Api
  module V1
    class PostsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_post, only: [:show, :update, :destroy, :like, :unlike]
      before_action :authorize_post_owner, only: [:update, :destroy]

      # GET /api/v1/posts
      def index
        @posts = Post.includes(:user, :likers).recent

        # Filtros
        @posts = @posts.by_user(params[:user_id]) if params[:user_id].present?
        @posts = @posts.with_tag(params[:tag]) if params[:tag].present?

        # Ordenamiento
        case params[:sort]
        when "oldest"
          @posts = @posts.oldest
        when "most_liked"
          @posts = @posts.most_liked
        when "most_commented"
          @posts = @posts.most_commented
        else
          @posts = @posts.recent
        end

        # Paginación
        @pagy, @posts = pagy(@posts, items: params[:per_page] || 20)

        render json: {
          posts: @posts.map { |post| post_json(post) },
          pagination: pagy_metadata(@pagy)
        }
      end

      # GET /api/v1/posts/:id
      def show
        render json: post_json(@post, detailed: true)
      end

      # POST /api/v1/posts
      def create
        @post = current_user.posts.build(post_params)

        if @post.save
          render json: post_json(@post), status: :created
        else
          render json: {errors: @post.errors.full_messages}, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/posts/:id
      def update
        if @post.update(post_params)
          render json: post_json(@post)
        else
          render json: {errors: @post.errors.full_messages}, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/posts/:id
      def destroy
        @post.destroy
        head :no_content
      end

      # POST /api/v1/posts/:id/like
      def like
        like = @post.likes.build(user: current_user)

        if like.save
          render json: {message: "Post liked successfully.", likes_count: @post.reload.likes_count}
        else
          render json: {errors: like.errors.full_messages}, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/posts/:id/unlike
      def unlike
        like = @post.likes.find_by(user: current_user)

        if like&.destroy
          render json: {message: "Post unliked successfully.", likes_count: @post.reload.likes_count}
        else
          render json: {error: "Like not found."}, status: :not_found
        end
      end

      private

      def set_post
        @post = Post.includes(:user, :likers, :comments).find(params[:id])
      end

      def authorize_post_owner
        render json: {error: "Unauthorized."}, status: :unauthorized unless @post.user_id == current_user.id
      end

      def post_params
        params.require(:post).permit(:content)
      end

      def post_json(post, detailed: false)
        json = {
          id: post.id,
          content: post.content,
          tags: post.tags,
          likes_count: post.likes_count,
          comments_count: post.comments_count,
          created_at: post.created_at,
          updated_at: post.updated_at,
          user: UserSerializer.new(post.user).as_json,
          liked_by_current_user: current_user ? post.liked_by?(current_user) : false
        }

        if detailed
          json[:recent_comments] = post.comments.recent.limit(5).map { |comment| comment_json(comment) }
        end

        json
      end

      def comment_json(comment)
        {
          id: comment.id,
          content: comment.content,
          created_at: comment.created_at,
          user: UserSerializer.new(comment.user).as_json
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

