class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  # Validations
  validates :content, presence: true

  # Associations
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  def likes_count
    likes.count
  end
end
