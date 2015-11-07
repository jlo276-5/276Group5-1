class CreateCourseMemberships < ActiveRecord::Migration
  def change
    create_table :course_memberships do |t|
      t.datetime :join_date
      t.integer :role, default: 0
      t.belongs_to :user, index: true, foreign_key: true
      t.belongs_to :course, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :course_memberships, [:user_id, :course_id], unique: true
  end
end
