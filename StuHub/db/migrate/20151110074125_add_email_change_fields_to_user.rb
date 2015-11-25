class AddEmailChangeFieldsToUser < ActiveRecord::Migration
  def change
    add_column :users, :email_change_digest, :string
    add_column :users, :email_change_new, :string
    add_column :users, :email_change_requested_at, :datetime
  end
end
