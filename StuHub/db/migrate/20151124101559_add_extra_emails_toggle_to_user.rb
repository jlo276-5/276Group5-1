class AddExtraEmailsToggleToUser < ActiveRecord::Migration
  def change
    add_column :users, :account_emails, :boolean, default: true
    add_column :users, :notification_emails, :boolean, default: false
  end
end
