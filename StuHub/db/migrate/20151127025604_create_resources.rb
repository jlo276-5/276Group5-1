class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :name, null: false
      t.text :description, default: ""
      t.attachment :resource, null: false
      t.references :group, index: true, foreign_key: true
      t.references :course, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
