class AddColumnsToInstitution < ActiveRecord::Migration
  def change
    add_column :institutions, :data_mode, :integer, default: 0
    add_column :institutions, :xlsx_db_url, :string
    add_column :institutions, :api_endpoint, :string
    add_column :institutions, :data_last_updated, :datetime
  end
end
