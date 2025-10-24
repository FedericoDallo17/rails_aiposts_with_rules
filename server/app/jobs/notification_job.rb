class NotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id:, notifiable_type:, notifiable_id:, event_type:)
    notification = Notification.create!(
      user_id: user_id,
      notifiable_type: notifiable_type,
      notifiable_id: notifiable_id,
      event_type: event_type
    )

    # Broadcast notification via Action Cable
    ActionCable.server.broadcast(
      "notifications:#{user_id}",
      {
        id: notification.id,
        event_type: notification.event_type,
        notifiable_type: notification.notifiable_type,
        notifiable_id: notification.notifiable_id,
        created_at: notification.created_at,
        read_at: notification.read_at
      }
    )
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error "Failed to create notification: #{e.message}"
  end
end
