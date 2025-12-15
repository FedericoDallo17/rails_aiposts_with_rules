class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :actor, class_name: "User", optional: true
  belongs_to :notifiable, polymorphic: true, optional: true

  # Validations
  validates :notification_type, presence: true

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :newest_first, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update(read_at: Time.current)
  end

  def mark_as_unread!
    update(read_at: nil)
  end
end
