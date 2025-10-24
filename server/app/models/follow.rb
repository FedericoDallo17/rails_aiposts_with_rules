class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Validations
  validates :follower_id, uniqueness: {scope: :followed_id}
  validate :cannot_follow_self

  # Callbacks
  after_create :notify_followed_user

  private

  def cannot_follow_self
    errors.add(:follower_id, "cannot follow yourself") if follower_id == followed_id
  end

  def notify_followed_user
    NotificationJob.perform_later(
      user_id: followed_id,
      notifiable_type: "Follow",
      notifiable_id: id,
      event_type: "follow"
    )
  end
end
