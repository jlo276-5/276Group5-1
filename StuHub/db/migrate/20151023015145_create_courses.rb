class CreateCourses < ActiveRecord::Migration
  def change
    create_table :years do |t|
      t.string :number # Ex. 2015

      t.timestamps null: false
    end

    create_table :terms do |t|
      t.string :name # Ex. Fall
      t.belongs_to :year, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :terms, [:name, :year_id], unique: true

    create_table :departments do |t|
      t.string :name # Ex. CMPT
      t.references :term, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :departments, [:name, :term_id], unique: true

    create_table :courses do |t|
      t.string :name # Ex. Intro to Software Engineering
      t.string :number # Ex. 276
      t.belongs_to :department, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :courses, [:number, :department_id], unique: true

    create_table :associated_classes do |t|
      t.integer :number # From API, a positive integer in a string
      t.belongs_to :course, index: true, foreign_key: true, unique: true

      t.timestamps null: false
    end

    add_index :associated_classes, [:number, :course_id], unique: true

    create_table :sections do |t|
      t.string :unique_number # Ex. 7367, not always present
      t.string :key # Ex. D100
      t.string :code # Ex. LEC
      t.belongs_to :associated_class, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :sections, [:key, :associated_class_id], unique: true

    create_table :section_times do |t|
      t.string :building # Ex. AQ
      t.string :room # Ex. 3182
      t.string :campus # Ex. Burnaby
      t.date :start_date # Ex. Tue Sep 08 00:00:00 PDT 2015
      t.date :end_date # Ex. Mon Dec 07 00:00:00 PST 2015
      t.time :start_time # Ex. 9:30
      t.time :end_time # Ex. 11:20
      t.string :days # Ex. Th
      t.belongs_to :section, index: true, foreign_key: true

      t.timestamps null: false
    end

    create_table :exams do |t|
      t.string :building # Ex. SSCC
      t.string :room # Ex. 9001
      t.string :campus # Ex. Burnaby
      t.datetime :exam_start # Ex. Sun Dec 13 15:30:00 PST 2015
      t.datetime :exam_end # Ex. Sun Dec 13 18:30:00 PST 2015
      t.belongs_to :section, index: true, foreign_key: true

      t.timestamps null: false
    end

    create_table :instructors do |t|
      t.string :first_name # Ex. John
      t.string :last_name # Ex. Smith
      t.string :email # Ex. jsmith@institute.com
      t.string :office # Ex. TASC9204, often not present
      t.string :office_hours # Ex. Th 12:30-15:30, often not present
      t.string :phone # Ex. 123-456-7890, often not present
      t.string :website # Ex. http://example.com/~jsmith/, often not present
      t.belongs_to :section, index: true, foreign_key: true

      t.timestamps null: false
    end

  end
end
