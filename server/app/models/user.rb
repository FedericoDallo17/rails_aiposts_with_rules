class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Active Storage attachments
  has_one_attached :profile_picture
  has_one_attached :cover_picture

  # Associations
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_posts, through: :likes, source: :post

  # Follows as follower (users I follow)
  has_many :following_relationships, class_name: "Follow", foreign_key: "follower_id", dependent: :destroy
  has_many :following, through: :following_relationships, source: :followed

  # Follows as followed (users who follow me)
  has_many :follower_relationships, class_name: "Follow", foreign_key: "followed_id", dependent: :destroy
  has_many :followers, through: :follower_relationships, source: :follower

  # Notifications
  has_many :notifications, dependent: :destroy

  # Validations
  validates :username, presence: true, uniqueness: {case_sensitive: false}, length: {minimum: 3, maximum: 30},
    format: {with: /\A[a-zA-Z0-9_]+\z/, message: "only allows letters, numbers and underscores"}
  validates :first_name, length: {maximum: 50}
  validates :last_name, length: {maximum: 50}
  validates :bio, length: {maximum: 500}
  validates :website, length: {maximum: 255}, format: {with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true}
  validates :location, length: {maximum: 100}

  # Image validations
  validate :profile_picture_validation
  validate :cover_picture_validation

  # Callbacks
  before_save :downcase_username

  # Instance methods
  def follow(user)
    following << user unless following.include?(user) || self == user
  end

  def unfollow(user)
    following.delete(user)
  end

  def following?(user)
    following.include?(user)
  end

  def full_name
    "#{first_name} #{last_name}".strip.presence || username
  end

  private

  def downcase_username
    self.username = username.downcase
  end

  def profile_picture_validation
    return unless profile_picture.attached?

    if profile_picture.blob.byte_size > 5.megabytes
      errors.add(:profile_picture, "is too large (maximum is 5MB)")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    unless acceptable_types.include?(profile_picture.blob.content_type)
      errors.add(:profile_picture, "must be a JPEG, PNG, GIF or WebP")
    end
  end

  def cover_picture_validation
    return unless cover_picture.attached?

    if cover_picture.blob.byte_size > 10.megabytes
      errors.add(:cover_picture, "is too large (maximum is 10MB)")
    end

    acceptable_types = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    unless acceptable_types.include?(cover_picture.blob.content_type)
      errors.add(:cover_picture, "must be a JPEG, PNG, GIF or WebP")
    end
  end
end
