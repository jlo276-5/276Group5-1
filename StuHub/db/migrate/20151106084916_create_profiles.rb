class CreateProfiles < ActiveRecord::Migration
  def change
    add_column :users, :major, :string, default: ""
    add_column :users, :about_me, :string, default: ""
    add_column :users, :website, :string, default: ""
    add_column :users, :birthday, :date
    add_column :users, :gender, :integer, default: 0 # 0 = Unspecfied, 1 = Male, 2 = Female

    create_table :institutions do |t|
      t.string :name, unique: true
      t.string :state
      t.string :country
      t.string :email_constraint, unique: true

      t.timestamps null: false
    end

    add_reference :users, :institution

    create_table :user_interests do |t|
      t.string :interest
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :user_interests, :interest

    create_table :privacy_settings do |t|
      t.boolean :display_institution, default: true
      t.boolean :display_major, default: true
      t.boolean :display_about_me, default: true
      t.boolean :display_email, default: false
      t.boolean :display_website, default: true
      t.boolean :display_birthday, default: false
      t.boolean :display_gender, default: false
      t.boolean :display_courses, default: true
      t.boolean :display_groups, default: true
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
