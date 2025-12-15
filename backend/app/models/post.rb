class Post < ApplicationRecord
  belongs_to :user

  # Validations
  validates :content, presence: true

  # Associations
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :reposts, dependent: :destroy
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Serialize tags as array
  serialize :tags, type: Array, coder: JSON

  # Scopes for search and sorting
  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :newest_first, -> { order(created_at: :desc) }
  scope :oldest_first, -> { order(created_at: :asc) }
  scope :most_liked, -> { left_joins(:likes).group(:id).order("COUNT(likes.id) DESC") }
  scope :most_commented, -> { left_joins(:comments).group(:id).order("COUNT(comments.id) DESC") }

  def likes_count
    likes.count
  end

  def comments_count
    comments.count
  end

  def reposts_count
    reposts.count
  end
end
