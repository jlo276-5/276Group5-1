class RemoveCurrentTermIdFromInstitution < ActiveRecord::Migration
  def change
    remove_column :institutions, :current_term_id
  end
end
