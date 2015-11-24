class RemoveYear < ActiveRecord::Migration
  def change
    drop_table :years
  end
end
