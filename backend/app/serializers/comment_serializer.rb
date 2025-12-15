class CommentSerializer
  def initialize(comment, current_user = nil)
    @comment = comment
    @current_user = current_user
  end

  def serializable_hash
    {
      id: @comment.id,
      content: @comment.content,
      user: UserSerializer.new(@comment.user).serializable_hash[:data][:attributes],
      post_id: @comment.post_id,
      likes_count: @comment.likes_count,
      liked_by_current_user: liked_by_current_user?,
      created_at: @comment.created_at,
      updated_at: @comment.updated_at
    }
  end

  private

  def liked_by_current_user?
    return false unless @current_user
    @comment.likes.exists?(user_id: @current_user.id)
  end
end
