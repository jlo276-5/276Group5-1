class AddFieldsToInstitution < ActiveRecord::Migration
  def change
    add_column :institutions, :website, :string
    add_column :institutions, :image, :string
    add_column :institutions, :city, :string
  end
end
