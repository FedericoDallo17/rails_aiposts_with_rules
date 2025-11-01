class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Validations
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  # Associations
  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :reposts, dependent: :destroy
  has_many :notifications, dependent: :destroy

  # Follower relationships
  has_many :following_relationships, class_name: "Follow", foreign_key: :follower_id, dependent: :destroy
  has_many :follower_relationships, class_name: "Follow", foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :following_relationships, source: :followed
  has_many :followers, through: :follower_relationships, source: :follower

  # Active Storage attachments
  has_one_attached :profile_picture_attachment
  has_one_attached :cover_picture_attachment
end
