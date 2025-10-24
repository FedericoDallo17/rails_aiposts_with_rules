class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true, index: true
      t.text :content, null: false
      t.string :tags, array: true, default: []
      t.integer :likes_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false

      t.timestamps
    end

    add_index :posts, :created_at
    add_index :posts, :likes_count
    add_index :posts, :comments_count
  end
end
