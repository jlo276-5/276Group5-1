class CreateGroupMemberships < ActiveRecord::Migration
  def change
    create_table :group_memberships do |t|
      t.datetime :join_date
      t.integer :role, default: 0
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :group, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :group_memberships, [:user_id, :group_id], unique: true
  end
end
