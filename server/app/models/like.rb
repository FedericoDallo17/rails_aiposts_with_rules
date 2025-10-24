class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Validations
  validates :user_id, uniqueness: {scope: :post_id}

  # Callbacks
  after_create :notify_post_author

  private

  def notify_post_author
    return if post.user_id == user_id

    NotificationJob.perform_later(
      user_id: post.user_id,
      notifiable_type: "Like",
      notifiable_id: id,
      event_type: "like"
    )
  end
end
