class AddIndexUserToInstitution < ActiveRecord::Migration
  def change
    add_index :users, :institution_id
  end
end
