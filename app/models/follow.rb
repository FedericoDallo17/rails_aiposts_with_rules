class Follow < ApplicationRecord
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"

  # Validations - a user can only follow another user once
  validates :follower_id, uniqueness: { scope: :followed_id }
  validates :follower_id, comparison: { other_than: :followed_id, message: "cannot follow themselves" }
  has_many :notifications, as: :notifiable, dependent: :destroy
end
