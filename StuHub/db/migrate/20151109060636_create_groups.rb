class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name, null: false, index: true, unique: true
      t.string :creator, null: false
      t.boolean :limited, default: false
      t.text :description

      t.timestamps null: false
    end
  end
end
