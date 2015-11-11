class AddCasAttributesToUser < ActiveRecord::Migration
  def change
    add_column :users, :cas_identifier, :string
    add_column :users, :cas_login_active, :boolean, default: false
  end
end
