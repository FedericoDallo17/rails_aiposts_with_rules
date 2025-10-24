class Post < ApplicationRecord
  include PgSearch::Model

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :likers, through: :likes, source: :user
  has_many :notifications, as: :notifiable, dependent: :destroy

  # Validations
  validates :content, presence: true, length: {minimum: 1, maximum: 5000}
  validates :tags, length: {maximum: 10}

  # Callbacks
  before_save :extract_tags
  after_create :extract_mentions

  # Counter cache
  # likes_count and comments_count are handled automatically with counter_cache option

  # PgSearch
  pg_search_scope :search_by_content,
    against: :content,
    using: {
      tsearch: {
        prefix: true,
        any_word: true
      },
      trigram: {
        threshold: 0.3
      }
    }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :oldest, -> { order(created_at: :asc) }
  scope :most_liked, -> { order(likes_count: :desc, created_at: :desc) }
  scope :most_commented, -> { order(comments_count: :desc, created_at: :desc) }
  scope :with_tag, ->(tag) { where("? = ANY(tags)", tag) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  # Instance methods
  def liked_by?(user)
    likes.exists?(user_id: user.id)
  end

  def mentioned_users
    content.scan(/@(\w+)/).flatten.map do |username|
      User.find_by(username: username.downcase)
    end.compact
  end

  private

  def extract_tags
    self.tags = content.scan(/#(\w+)/).flatten.map(&:downcase).uniq[0...10]
  end

  def extract_mentions
    MentionExtractorJob.perform_later(id) if mentioned_users.any?
  end
end
