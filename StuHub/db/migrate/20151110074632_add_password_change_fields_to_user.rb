class AddPasswordChangeFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :password_change_digest, :string
    add_column :users, :password_change_requested_at, :datetime
  end
end
