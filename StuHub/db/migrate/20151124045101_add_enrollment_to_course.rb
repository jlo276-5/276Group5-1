class AddEnrollmentToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :enrollment, :text, default: ""
  end
end
