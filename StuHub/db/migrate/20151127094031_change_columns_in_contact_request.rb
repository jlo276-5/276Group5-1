class ChangeColumnsInContactRequest < ActiveRecord::Migration
  def change
    rename_column :contact_requests, :type, :contact_type
    add_column :contact_requests, :resolved, :boolean, default: false
  end
end
