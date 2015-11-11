class AddIndexCasIdentifierToUser < ActiveRecord::Migration
  def change
    add_index :users, :cas_identifier, unique: true
  end
end
