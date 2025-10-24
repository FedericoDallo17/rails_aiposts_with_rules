class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Validations
  validates :content, presence: true, length: {minimum: 1, maximum: 1000}

  # Callbacks
  after_create :notify_post_author
  after_create :notify_mentioned_users

  # Scopes
  scope :recent, -> { order(created_at: :desc) }

  def mentioned_users
    content.scan(/@(\w+)/).flatten.map do |username|
      User.find_by(username: username.downcase)
    end.compact
  end

  private

  def notify_post_author
    return if post.user_id == user_id

    NotificationJob.perform_later(
      user_id: post.user_id,
      notifiable_type: "Comment",
      notifiable_id: id,
      event_type: "comment"
    )
  end

  def notify_mentioned_users
    mentioned_users.each do |mentioned_user|
      next if mentioned_user.id == user_id

      NotificationJob.perform_later(
        user_id: mentioned_user.id,
        notifiable_type: "Comment",
        notifiable_id: id,
        event_type: "mention"
      )
    end
  end
end
