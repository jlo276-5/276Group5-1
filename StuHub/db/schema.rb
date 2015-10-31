# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151023015145) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "associated_classes", force: :cascade do |t|
    t.integer  "number"
    t.integer  "course_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "associated_classes", ["course_id"], name: "index_associated_classes_on_course_id", using: :btree
  add_index "associated_classes", ["number", "course_id"], name: "index_associated_classes_on_number_and_course_id", unique: true, using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "name"
    t.string   "number"
    t.integer  "department_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "courses", ["department_id"], name: "index_courses_on_department_id", using: :btree
  add_index "courses", ["number", "department_id"], name: "index_courses_on_number_and_department_id", unique: true, using: :btree

  create_table "departments", force: :cascade do |t|
    t.string   "name"
    t.integer  "term_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "departments", ["name", "term_id"], name: "index_departments_on_name_and_term_id", unique: true, using: :btree
  add_index "departments", ["term_id"], name: "index_departments_on_term_id", using: :btree

  create_table "exams", force: :cascade do |t|
    t.string   "building"
    t.string   "room"
    t.string   "campus"
    t.datetime "exam_start"
    t.datetime "exam_end"
    t.integer  "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "exams", ["section_id"], name: "index_exams_on_section_id", using: :btree

  create_table "instructors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "office"
    t.string   "office_hours"
    t.string   "phone"
    t.string   "website"
    t.integer  "section_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "instructors", ["section_id"], name: "index_instructors_on_section_id", using: :btree

  create_table "section_times", force: :cascade do |t|
    t.string   "building"
    t.string   "room"
    t.string   "campus"
    t.date     "start_date"
    t.date     "end_date"
    t.time     "start_time"
    t.time     "end_time"
    t.string   "days"
    t.integer  "section_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "section_times", ["section_id"], name: "index_section_times_on_section_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "unique_number"
    t.string   "key"
    t.string   "code"
    t.integer  "associated_class_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "sections", ["associated_class_id"], name: "index_sections_on_associated_class_id", using: :btree
  add_index "sections", ["key", "associated_class_id"], name: "index_sections_on_key_and_associated_class_id", unique: true, using: :btree

  create_table "terms", force: :cascade do |t|
    t.string   "name"
    t.integer  "year_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "terms", ["name", "year_id"], name: "index_terms_on_name_and_year_id", unique: true, using: :btree
  add_index "terms", ["year_id"], name: "index_terms_on_year_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "activation_digest"
    t.boolean  "activated",         default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.integer  "role",              default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "years", force: :cascade do |t|
    t.string   "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "associated_classes", "courses"
  add_foreign_key "courses", "departments"
  add_foreign_key "departments", "terms"
  add_foreign_key "exams", "sections"
  add_foreign_key "instructors", "sections"
  add_foreign_key "section_times", "sections"
  add_foreign_key "sections", "associated_classes"
  add_foreign_key "terms", "years"
end
