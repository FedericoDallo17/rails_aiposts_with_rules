module Api
  module V1
    class CommentsController < BaseController
      before_action :set_post, only: [ :index, :create ]
      before_action :set_comment, only: [ :show, :update, :destroy, :like, :unlike ]
      skip_before_action :authenticate_user!, only: [ :index, :show ]

      def index
        comments = @post.comments.includes(:user, :likes).page(params[:page]).per(params[:per_page] || 20)
        render json: {
          comments: comments.map { |c| CommentSerializer.new(c, current_user).serializable_hash },
          meta: pagination_meta(comments)
        }
      end

      def show
        render json: CommentSerializer.new(@comment, current_user).serializable_hash
      end

      def create
        comment = @post.comments.build(comment_params.merge(user: current_user))
        if comment.save
          create_comment_notification(comment)
          render json: CommentSerializer.new(comment, current_user).serializable_hash, status: :created
        else
          render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize_comment!
        if @comment.update(comment_params)
          render json: CommentSerializer.new(@comment, current_user).serializable_hash
        else
          render json: { errors: @comment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize_comment!
        @comment.destroy
        render json: { message: "Comment deleted successfully" }
      end

      def like
        like = @comment.likes.build(user: current_user)
        if like.save
          create_like_notification(like)
          render json: { message: "Comment liked successfully", likes_count: @comment.likes_count }
        else
          render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def unlike
        like = @comment.likes.find_by(user: current_user)
        if like
          like.destroy
          render json: { message: "Comment unliked successfully", likes_count: @comment.likes_count }
        else
          render json: { error: "Like not found" }, status: :not_found
        end
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
      end

      def set_comment
        @comment = Comment.find(params[:id])
      end

      def authorize_comment!
        unless current_user.id == @comment.user_id
          render json: { error: "Unauthorized" }, status: :forbidden
        end
      end

      def comment_params
        params.require(:comment).permit(:content)
      end

      def create_comment_notification(comment)
        return if comment.post.user_id == current_user.id

        Notification.create(
          user: comment.post.user,
          actor: current_user,
          notifiable: comment,
          notification_type: "comment",
          message: "#{current_user.username} commented on your post"
        )
      end

      def create_like_notification(like)
        return if @comment.user_id == current_user.id

        Notification.create(
          user: @comment.user,
          actor: current_user,
          notifiable: like,
          notification_type: "comment_like",
          message: "#{current_user.username} liked your comment"
        )
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
