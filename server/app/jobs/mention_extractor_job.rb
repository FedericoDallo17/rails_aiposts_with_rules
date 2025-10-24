class MentionExtractorJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find_by(id: post_id)
    return unless post

    post.mentioned_users.each do |mentioned_user|
      next if mentioned_user.id == post.user_id

      NotificationJob.perform_later(
        user_id: mentioned_user.id,
        notifiable_type: "Post",
        notifiable_id: post.id,
        event_type: "mention"
      )
    end
  rescue StandardError => e
    Rails.logger.error "Failed to extract mentions: #{e.message}"
  end
end
