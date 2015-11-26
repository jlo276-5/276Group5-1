class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :title
      t.text :body
      t.integer :channel_type, default: 0, null: false
      t.integer :channel_id, default: 0, null: false
      t.references :user, null: false

      t.timestamps null: false
    end

    add_index :posts, [:channel_id, :channel_type]
    add_index :posts, :user_id
  end
end
