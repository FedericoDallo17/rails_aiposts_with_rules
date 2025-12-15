module Api
  module V1
    class PostsController < BaseController
      before_action :set_post, only: [ :show, :update, :destroy, :like, :unlike, :repost, :unrepost, :reposts ]
      skip_before_action :authenticate_user!, only: [ :index, :show ]

      def index
        posts = Post.includes(:user, :likes, :comments, :reposts).newest_first
                    .page(params[:page]).per(params[:per_page] || 20)
        render json: {
          posts: posts.map { |p| PostSerializer.new(p, current_user).serializable_hash },
          meta: pagination_meta(posts)
        }
      end

      def show
        render json: PostSerializer.new(@post, current_user).serializable_hash
      end

      def create
        post = current_user.posts.build(post_params)
        if post.save
          create_mention_notifications(post)
          render json: PostSerializer.new(post, current_user).serializable_hash, status: :created
        else
          render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        authorize_post!
        if @post.update(post_params)
          render json: PostSerializer.new(@post, current_user).serializable_hash
        else
          render json: { errors: @post.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        authorize_post!
        @post.destroy
        render json: { message: "Post deleted successfully" }
      end

      def like
        like = @post.likes.build(user: current_user)
        if like.save
          create_like_notification(like)
          render json: { message: "Post liked successfully", likes_count: @post.likes_count }
        else
          render json: { errors: like.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def unlike
        like = @post.likes.find_by(user: current_user)
        if like
          like.destroy
          render json: { message: "Post unliked successfully", likes_count: @post.likes_count }
        else
          render json: { error: "Like not found" }, status: :not_found
        end
      end

      def repost
        repost = current_user.reposts.build(post: @post)
        if repost.save
          create_repost_notification(repost)
          render json: { message: "Post reposted successfully", reposts_count: @post.reposts_count }
        else
          render json: { errors: repost.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def unrepost
        repost = current_user.reposts.find_by(post: @post)
        if repost
          repost.destroy
          render json: { message: "Repost removed successfully", reposts_count: @post.reposts_count }
        else
          render json: { error: "Repost not found" }, status: :not_found
        end
      end

      def reposts
        reposts = @post.reposts.includes(:user).page(params[:page]).per(params[:per_page] || 20)
        render json: {
          reposts: reposts.map { |r| { user: UserSerializer.new(r.user).serializable_hash[:data][:attributes], created_at: r.created_at } },
          meta: pagination_meta(reposts)
        }
      end

      private

      def set_post
        @post = Post.find(params[:id])
      end

      def authorize_post!
        unless current_user.id == @post.user_id
          render json: { error: "Unauthorized" }, status: :forbidden
        end
      end

      def post_params
        params.require(:post).permit(:content, tags: [])
      end

      def create_mention_notifications(post)
        mentions = post.content.scan(/@(\w+)/).flatten
        mentions.each do |username|
          mentioned_user = User.find_by(username: username)
          next unless mentioned_user && mentioned_user.id != current_user.id

          Notification.create(
            user: mentioned_user,
            actor: current_user,
            notifiable: post,
            notification_type: "mention",
            message: "#{current_user.username} mentioned you in a post"
          )
        end
      end

      def create_like_notification(like)
        return if @post.user_id == current_user.id

        Notification.create(
          user: @post.user,
          actor: current_user,
          notifiable: like,
          notification_type: "like",
          message: "#{current_user.username} liked your post"
        )
      end

      def create_repost_notification(repost)
        return if @post.user_id == current_user.id

        Notification.create(
          user: @post.user,
          actor: current_user,
          notifiable: repost,
          notification_type: "repost",
          message: "#{current_user.username} reposted your post"
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
