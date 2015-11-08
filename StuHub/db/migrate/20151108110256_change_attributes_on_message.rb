class ChangeAttributesOnMessage < ActiveRecord::Migration
  def change
    add_column :messages, :user_id, :integer
    add_column :messages, :channel_type, :integer, default: 0, null: false
    add_column :messages, :channel_id, :integer, default: 0, null: false

    add_index :messages, [:channel_type, :channel_id]
  end
end
