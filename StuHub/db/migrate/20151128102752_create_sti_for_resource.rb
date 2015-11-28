class CreateStiForResource < ActiveRecord::Migration
  def change
    add_column :resources, :type, :string
    add_column :resources, :category, :integer, default: 0
  end
end
