class ChangeColumnNameInGroup < ActiveRecord::Migration
  def up
    change_column :groups, :name, :string, null: true
    change_column :groups, :creator, :string, null: true
  end

  def down
    change_column :groups, :name, :string, null: false
    change_column :groups, :creator, :string, null: false
  end
end
