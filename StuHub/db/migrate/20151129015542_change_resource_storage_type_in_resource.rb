class ChangeResourceStorageTypeInResource < ActiveRecord::Migration
  def change
    add_column :resources, :file_name, :string, null: false
    add_column :resources, :content_type, :string, null: false
  end
end
