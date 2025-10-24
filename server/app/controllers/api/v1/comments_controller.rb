module Api
  module V1
    class CommentsController < BaseController
      skip_before_action :authenticate_user!, only: [:index, :show]
      before_action :set_post, only: [:index, :create]
      before_action :set_comment, only: [:show, :update, :destroy]
      before_action :authorize_comment_owner, only: [:update, :destroy]

      # GET /api/v1/posts/:post_id/comments
      def index
        @comments = @post.comments.includes(:user).recent
        @pagy, @comments = pagy(@comments, items: params[:per_page] || 20)

        render json: {
          comments: @comments.map { |comment| comment_json(comment) },
          pagination: pagy_metadata(@pagy)
        }
      end

      # GET /api/v1/comments/:id
      def show
        render json: comment_json(@comment)
      end

      # POST /api/v1/posts/:post_id/comments
      def create
        @comment = @post.comments.build(comment_params.merge(user: current_user))

        if @comment.save
          render json: comment_json(@comment), status: :created
        else
          render json: {errors: @comment.errors.full_messages}, status: :unprocessable_entity
        end
      end

      # PUT /api/v1/comments/:id
      def update
        if @comment.update(comment_params)
          render json: comment_json(@comment)
        else
          render json: {errors: @comment.errors.full_messages}, status: :unprocessable_entity
        end
      end

      # DELETE /api/v1/comments/:id
      def destroy
        @comment.destroy
        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def set_comment
        @comment = Comment.includes(:user, :post).find(params[:id])
      end

      def authorize_comment_owner
        render json: {error: "Unauthorized."}, status: :unauthorized unless @comment.user_id == current_user.id
      end

      def comment_params
        params.require(:comment).permit(:content)
      end

      def comment_json(comment)
        {
          id: comment.id,
          content: comment.content,
          created_at: comment.created_at,
          updated_at: comment.updated_at,
          user: UserSerializer.new(comment.user).as_json,
          post_id: comment.post_id
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

