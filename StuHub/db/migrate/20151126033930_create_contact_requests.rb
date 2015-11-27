class CreateContactRequests < ActiveRecord::Migration
  def change
    create_table :contact_requests do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :title, default: ""
      t.text :body
      t.integer :type, default: 0
      t.boolean :reply, default: false

      t.timestamps null: false
    end
  end
end
