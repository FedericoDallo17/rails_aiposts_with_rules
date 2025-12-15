class Repost < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # Validations - a user can only repost a post once
  validates :user_id, uniqueness: { scope: :post_id }
  has_many :notifications, as: :notifiable, dependent: :destroy
end
