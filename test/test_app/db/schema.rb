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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110517184623) do

  create_table "contactable_objects", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "formageddon_browser_states", :force => true do |t|
    t.text     "uri"
    t.text     "cookie_jar"
    t.text     "raw_html"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formageddon_contact_steps", :force => true do |t|
    t.integer "formageddon_recipient_id"
    t.string  "formageddon_recipient_type"
    t.integer "step_number"
    t.string  "command"
  end

  create_table "formageddon_delivery_attempts", :force => true do |t|
    t.integer  "formageddon_letter_id"
    t.string   "result"
    t.integer  "letter_contact_step"
    t.text     "before_browser_state_id"
    t.text     "after_browser_state_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formageddon_form_captcha_images", :force => true do |t|
    t.integer "formageddon_form_id"
    t.integer "image_number"
    t.string  "css_selector"
  end

  create_table "formageddon_form_fields", :force => true do |t|
    t.integer "formageddon_form_id"
    t.integer "field_number"
    t.string  "name"
    t.string  "value"
  end

  create_table "formageddon_forms", :force => true do |t|
    t.integer "formageddon_contact_step_id"
    t.integer "form_number"
    t.boolean "use_field_names"
    t.string  "success_string"
  end

  create_table "formageddon_letters", :force => true do |t|
    t.integer  "formageddon_thread_id"
    t.string   "direction"
    t.string   "status"
    t.string   "issue_area"
    t.string   "subject"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "formageddon_threads", :force => true do |t|
    t.integer  "formageddon_recipient_id"
    t.string   "formageddon_recipient_type"
    t.string   "sender_title"
    t.string   "sender_first_name"
    t.string   "sender_last_name"
    t.string   "sender_address1"
    t.string   "sender_address2"
    t.string   "sender_city"
    t.string   "sender_state"
    t.string   "sender_zip5"
    t.string   "sender_zip4"
    t.string   "sender_phone"
    t.string   "sender_email"
    t.string   "privacy"
    t.integer  "formageddon_sender_id"
    t.string   "formageddon_sender_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                               :default => "",    :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "",    :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.boolean  "admin",                               :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
