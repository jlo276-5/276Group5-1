class ChangeUserTypeInUser < ActiveRecord::Migration
  def up
    remove_column :users, :admin
    add_column :users, :role, :integer, default: 0
  end

  def down
    add_column :users, :admin, :boolean, default: false
    remove_column :users, :role
  end
end
