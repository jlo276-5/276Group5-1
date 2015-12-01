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

ActiveRecord::Schema.define(version: 20151201033146) do

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

  create_table "contact_requests", force: :cascade do |t|
    t.string   "name",                         null: false
    t.string   "email",                        null: false
    t.string   "title",        default: ""
    t.text     "body"
    t.integer  "contact_type", default: 0
    t.boolean  "reply",        default: false
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.boolean  "resolved",     default: false
  end

  create_table "course_memberships", force: :cascade do |t|
    t.datetime "join_date"
    t.integer  "role",            default: 0
    t.integer  "user_id"
    t.integer  "course_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "last_visited_at"
  end

  add_index "course_memberships", ["course_id"], name: "index_course_memberships_on_course_id", using: :btree
  add_index "course_memberships", ["user_id", "course_id"], name: "index_course_memberships_on_user_id_and_course_id", unique: true, using: :btree
  add_index "course_memberships", ["user_id"], name: "index_course_memberships_on_user_id", using: :btree

  create_table "course_memberships_sections", id: false, force: :cascade do |t|
    t.integer "course_membership_id", null: false
    t.integer "section_id",           null: false
  end

  add_index "course_memberships_sections", ["course_membership_id", "section_id"], name: "index_cms_on_cm_id_and_section_id", unique: true, using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "name"
    t.string   "number"
    t.integer  "department_id"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "enrollment",    default: ""
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

  create_table "events", force: :cascade do |t|
    t.string   "title"
    t.text     "description"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "user_id"
    t.boolean  "if_background"
  end

  add_index "events", ["user_id"], name: "index_events_on_user_id", using: :btree

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

  create_table "group_membership_requests", force: :cascade do |t|
    t.string   "request_message"
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "group_membership_requests", ["group_id"], name: "index_group_membership_requests_on_group_id", using: :btree
  add_index "group_membership_requests", ["user_id", "group_id"], name: "index_group_membership_requests_on_user_id_and_group_id", unique: true, using: :btree
  add_index "group_membership_requests", ["user_id"], name: "index_group_membership_requests_on_user_id", using: :btree

  create_table "group_memberships", force: :cascade do |t|
    t.integer  "role",            default: 0
    t.integer  "user_id"
    t.integer  "group_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.datetime "last_visited_at"
  end

  add_index "group_memberships", ["group_id"], name: "index_group_memberships_on_group_id", using: :btree
  add_index "group_memberships", ["user_id", "group_id"], name: "index_group_memberships_on_user_id_and_group_id", unique: true, using: :btree
  add_index "group_memberships", ["user_id"], name: "index_group_memberships_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name"
    t.string   "creator"
    t.boolean  "limited",        default: false
    t.text     "description"
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.integer  "institution_id"
  end

  add_index "groups", ["institution_id"], name: "index_groups_on_institution_id", using: :btree
  add_index "groups", ["name"], name: "index_groups_on_name", using: :btree

  create_table "institutions", force: :cascade do |t|
    t.string   "name"
    t.string   "state"
    t.string   "country"
    t.string   "email_constraint"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "website"
    t.string   "image"
    t.string   "city"
    t.boolean  "uses_cas",         default: false
    t.string   "cas_endpoint"
  end

  add_index "institutions", ["uses_cas"], name: "index_institutions_on_uses_cas", using: :btree

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

  create_table "mailboxer_conversation_opt_outs", force: :cascade do |t|
    t.integer "unsubscriber_id"
    t.string  "unsubscriber_type"
    t.integer "conversation_id"
  end

  add_index "mailboxer_conversation_opt_outs", ["conversation_id"], name: "index_mailboxer_conversation_opt_outs_on_conversation_id", using: :btree
  add_index "mailboxer_conversation_opt_outs", ["unsubscriber_id", "unsubscriber_type"], name: "index_mailboxer_conversation_opt_outs_on_unsubscriber_id_type", using: :btree

  create_table "mailboxer_conversations", force: :cascade do |t|
    t.string   "subject",    default: ""
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "mailboxer_notifications", force: :cascade do |t|
    t.string   "type"
    t.text     "body"
    t.string   "subject",              default: ""
    t.integer  "sender_id"
    t.string   "sender_type"
    t.integer  "conversation_id"
    t.boolean  "draft",                default: false
    t.string   "notification_code"
    t.integer  "notified_object_id"
    t.string   "notified_object_type"
    t.string   "attachment"
    t.datetime "updated_at",                           null: false
    t.datetime "created_at",                           null: false
    t.boolean  "global",               default: false
    t.datetime "expires"
  end

  add_index "mailboxer_notifications", ["conversation_id"], name: "index_mailboxer_notifications_on_conversation_id", using: :btree
  add_index "mailboxer_notifications", ["notified_object_id", "notified_object_type"], name: "index_mailboxer_notifications_on_notified_object_id_and_type", using: :btree
  add_index "mailboxer_notifications", ["sender_id", "sender_type"], name: "index_mailboxer_notifications_on_sender_id_and_sender_type", using: :btree
  add_index "mailboxer_notifications", ["type"], name: "index_mailboxer_notifications_on_type", using: :btree

  create_table "mailboxer_receipts", force: :cascade do |t|
    t.integer  "receiver_id"
    t.string   "receiver_type"
    t.integer  "notification_id",                            null: false
    t.boolean  "is_read",                    default: false
    t.boolean  "trashed",                    default: false
    t.boolean  "deleted",                    default: false
    t.string   "mailbox_type",    limit: 25
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "mailboxer_receipts", ["notification_id"], name: "index_mailboxer_receipts_on_notification_id", using: :btree
  add_index "mailboxer_receipts", ["receiver_id", "receiver_type"], name: "index_mailboxer_receipts_on_receiver_id_and_receiver_type", using: :btree

  create_table "messages", force: :cascade do |t|
    t.text     "content"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id"
    t.integer  "channel_type", default: 0, null: false
    t.integer  "channel_id",   default: 0, null: false
  end

  add_index "messages", ["channel_type", "channel_id"], name: "index_messages_on_channel_type_and_channel_id", using: :btree

  create_table "posts", force: :cascade do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "channel_type", default: 0, null: false
    t.integer  "channel_id",   default: 0, null: false
    t.integer  "user_id",                  null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "posts", ["channel_id", "channel_type"], name: "index_posts_on_channel_id_and_channel_type", using: :btree
  add_index "posts", ["user_id"], name: "index_posts_on_user_id", using: :btree

  create_table "privacy_settings", force: :cascade do |t|
    t.boolean  "display_institution", default: true
    t.boolean  "display_major",       default: true
    t.boolean  "display_about_me",    default: true
    t.boolean  "display_email",       default: false
    t.boolean  "display_website",     default: true
    t.boolean  "display_birthday",    default: false
    t.boolean  "display_gender",      default: false
    t.boolean  "display_courses",     default: true
    t.boolean  "display_groups",      default: true
    t.integer  "user_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "display_schedule",    default: false
  end

  add_index "privacy_settings", ["user_id"], name: "index_privacy_settings_on_user_id", using: :btree

  create_table "resources", force: :cascade do |t|
    t.string   "name",                      null: false
    t.text     "description",  default: ""
    t.integer  "group_id"
    t.integer  "course_id"
    t.integer  "user_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "type"
    t.integer  "category",     default: 0
    t.string   "file_name",                 null: false
    t.string   "content_type",              null: false
  end

  add_index "resources", ["course_id"], name: "index_resources_on_course_id", using: :btree
  add_index "resources", ["group_id"], name: "index_resources_on_group_id", using: :btree
  add_index "resources", ["user_id"], name: "index_resources_on_user_id", using: :btree

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

  create_table "settings", force: :cascade do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true, using: :btree

  create_table "terms", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.integer  "year"
    t.string   "term_reference"
    t.string   "data_url"
    t.datetime "data_last_updated"
    t.integer  "institution_id"
    t.date     "enrollment_start_date"
    t.date     "start_date"
    t.date     "end_date"
    t.date     "exams_end_date"
    t.integer  "data_mode",                    default: 0
    t.string   "database_url"
    t.boolean  "database_contains_enrollment", default: false
    t.boolean  "updating",                     default: false
    t.integer  "term_order",                   default: 1
    t.integer  "database_last_line",           default: 0
  end

  add_index "terms", ["institution_id", "term_reference"], name: "index_terms_on_institution_id_and_term_reference", unique: true, using: :btree
  add_index "terms", ["institution_id"], name: "index_terms_on_institution_id", using: :btree

  create_table "user_interests", force: :cascade do |t|
    t.string   "interest"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_interests", ["interest"], name: "index_user_interests_on_interest", using: :btree
  add_index "user_interests", ["user_id"], name: "index_user_interests_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at",                                                          null: false
    t.datetime "updated_at",                                                          null: false
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "activation_digest"
    t.boolean  "activated",                    default: false
    t.datetime "activated_at"
    t.string   "reset_digest"
    t.datetime "reset_sent_at"
    t.integer  "role",                         default: 0
    t.datetime "last_active_at"
    t.string   "time_zone",                    default: "Pacific Time (US & Canada)"
    t.string   "major",                        default: ""
    t.text     "about_me",                     default: ""
    t.string   "website",                      default: ""
    t.date     "birthday"
    t.integer  "gender",                       default: 0
    t.integer  "institution_id"
    t.datetime "last_login_at"
    t.string   "email_change_digest"
    t.string   "email_change_new"
    t.datetime "email_change_requested_at"
    t.string   "password_change_digest"
    t.datetime "password_change_requested_at"
    t.string   "cas_identifier"
    t.boolean  "cas_login_active",             default: false
    t.string   "dropbox_token"
    t.string   "dropbox_secret"
    t.string   "dropbox_uid"
    t.boolean  "account_emails",               default: true
    t.boolean  "notification_emails",          default: false
    t.integer  "failed_login_attempts",        default: 0
    t.boolean  "account_locked",               default: false
  end

  add_index "users", ["cas_identifier"], name: "index_users_on_cas_identifier", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["institution_id"], name: "index_users_on_institution_id", using: :btree

  add_foreign_key "associated_classes", "courses"
  add_foreign_key "course_memberships", "courses"
  add_foreign_key "course_memberships", "users"
  add_foreign_key "courses", "departments"
  add_foreign_key "departments", "terms"
  add_foreign_key "events", "users"
  add_foreign_key "exams", "sections"
  add_foreign_key "group_membership_requests", "groups"
  add_foreign_key "group_membership_requests", "users"
  add_foreign_key "group_memberships", "groups"
  add_foreign_key "group_memberships", "users"
  add_foreign_key "groups", "institutions"
  add_foreign_key "instructors", "sections"
  add_foreign_key "mailboxer_conversation_opt_outs", "mailboxer_conversations", column: "conversation_id", name: "mb_opt_outs_on_conversations_id"
  add_foreign_key "mailboxer_notifications", "mailboxer_conversations", column: "conversation_id", name: "notifications_on_conversation_id"
  add_foreign_key "mailboxer_receipts", "mailboxer_notifications", column: "notification_id", name: "receipts_on_notification_id"
  add_foreign_key "privacy_settings", "users"
  add_foreign_key "resources", "courses"
  add_foreign_key "resources", "groups"
  add_foreign_key "resources", "users"
  add_foreign_key "section_times", "sections"
  add_foreign_key "sections", "associated_classes"
  add_foreign_key "terms", "institutions"
  add_foreign_key "user_interests", "users"
end
