class AddLoginAttemptsLockToUser < ActiveRecord::Migration
  def change
    add_column :users, :failed_login_attempts, :integer, default: 0
    add_column :users, :account_locked, :boolean, default: false
  end
end
