class CreateGroupMembershipRequests < ActiveRecord::Migration
  def change
    create_table :group_membership_requests do |t|
      t.string :request_message
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :group, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :group_membership_requests, [:user_id, :group_id], unique: true
  end
end
