class RemoveColumnFromGroupMembership < ActiveRecord::Migration
  def up
    remove_column :group_memberships, :join_date
  end

  def down
    add_column :group_memberships, :join_date, :datetime
  end
end
