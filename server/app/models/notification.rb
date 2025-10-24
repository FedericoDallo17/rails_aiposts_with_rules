class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  # Validations
  validates :event_type, presence: true, inclusion: {in: %w[like comment follow mention]}

  # Scopes
  scope :unread, -> { where(read_at: nil) }
  scope :read, -> { where.not(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  # Instance methods
  def read?
    read_at.present?
  end

  def mark_as_read!
    update(read_at: Time.current) unless read?
  end

  def mark_as_unread!
    update(read_at: nil) if read?
  end
end
