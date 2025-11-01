class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  # Validations
  validates :user_id, uniqueness: { scope: [ :likeable_type, :likeable_id ] }
  has_many :notifications, as: :notifiable, dependent: :destroy
end
