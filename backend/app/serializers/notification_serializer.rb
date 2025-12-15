class NotificationSerializer
  def initialize(notification)
    @notification = notification
  end

  def serializable_hash
    {
      id: @notification.id,
      message: @notification.message,
      notification_type: @notification.notification_type,
      read: @notification.read?,
      read_at: @notification.read_at,
      actor: actor_data,
      notifiable: notifiable_data,
      created_at: @notification.created_at
    }
  end

  private

  def actor_data
    return nil unless @notification.actor
    UserSerializer.new(@notification.actor).serializable_hash[:data][:attributes]
  end

  def notifiable_data
    return nil unless @notification.notifiable

    case @notification.notifiable
    when Post
      { type: "Post", id: @notification.notifiable.id }
    when Comment
      { type: "Comment", id: @notification.notifiable.id, post_id: @notification.notifiable.post_id }
    when Like
      { type: "Like", id: @notification.notifiable.id }
    when Repost
      { type: "Repost", id: @notification.notifiable.id, post_id: @notification.notifiable.post_id }
    when Follow
      { type: "Follow", id: @notification.notifiable.id }
    else
      nil
    end
  end
end
