class PostSerializer
  def initialize(post, current_user = nil)
    @post = post
    @current_user = current_user
  end

  def serializable_hash
    {
      id: @post.id,
      content: @post.content,
      tags: @post.tags,
      user: UserSerializer.new(@post.user).serializable_hash[:data][:attributes],
      likes_count: @post.likes_count,
      comments_count: @post.comments_count,
      reposts_count: @post.reposts_count,
      liked_by_current_user: liked_by_current_user?,
      reposted_by_current_user: reposted_by_current_user?,
      created_at: @post.created_at,
      updated_at: @post.updated_at
    }
  end

  private

  def liked_by_current_user?
    return false unless @current_user
    @post.likes.exists?(user_id: @current_user.id)
  end

  def reposted_by_current_user?
    return false unless @current_user
    @post.reposts.exists?(user_id: @current_user.id)
  end
end
