class AddDateFieldsToTerm < ActiveRecord::Migration
  def change
    add_column :terms, :enrollment_start_date, :date
    add_column :terms, :start_date, :date
    add_column :terms, :end_date, :date
    add_column :terms, :exams_end_date, :date
  end
end
