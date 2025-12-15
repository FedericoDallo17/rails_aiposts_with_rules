class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.text :message
      t.string :notification_type
      t.datetime :read_at
      t.references :user, null: false, foreign_key: true
      t.integer :actor_id
      t.references :notifiable, polymorphic: true, null: false

      t.timestamps
    end
  end
end
