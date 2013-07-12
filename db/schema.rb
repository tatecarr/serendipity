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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130712144236) do

  create_table "dbpedia_infos", :force => true do |t|
    t.string   "info_type_desc"
    t.integer  "entity_type_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "dbpedia_logs", :force => true do |t|
    t.integer  "source_id"
    t.integer  "source_type"
    t.integer  "info_type_id"
    t.string   "status"
    t.integer  "added_relationships"
    t.string   "log_message"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  create_table "entity_types", :force => true do |t|
    t.string   "entity_type_desc"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  create_table "people", :force => true do |t|
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "fb_link"
    t.string   "fb_username"
    t.date     "birthday"
    t.string   "gender"
    t.string   "interested_in"
    t.string   "political"
    t.string   "email"
    t.integer  "timezone"
    t.string   "locale"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.boolean  "person_populated"
    t.string   "uid"
    t.string   "resource_id"
  end

  create_table "places", :force => true do |t|
    t.decimal  "lat",        :precision => 12, :scale => 4
    t.decimal  "long",       :precision => 12, :scale => 4
    t.string   "name"
    t.string   "type_desc"
    t.string   "tags"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "populated_infos", :force => true do |t|
    t.integer  "source_id"
    t.integer  "source_type"
    t.integer  "dbpedia_info_id"
    t.boolean  "is_populated"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "relationship_types", :force => true do |t|
    t.string   "relationship_desc"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "relationships", :force => true do |t|
    t.integer  "source_id"
    t.integer  "source_type"
    t.integer  "target_id"
    t.integer  "target_type"
    t.integer  "relationship_type"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.date     "relationship_date"
    t.integer  "ymddate_id"
  end

  add_index "relationships", ["id"], :name => "index_relationships_on_id"
  add_index "relationships", ["relationship_type"], :name => "index_relationships_on_relationship_type"
  add_index "relationships", ["source_id"], :name => "index_relationships_on_source_id"
  add_index "relationships", ["source_type"], :name => "index_relationships_on_source_type"
  add_index "relationships", ["target_id"], :name => "index_relationships_on_target_id"
  add_index "relationships", ["target_type"], :name => "index_relationships_on_target_type"
  add_index "relationships", ["ymddate_id"], :name => "index_relationships_on_ymddate_id"

  create_table "things", :force => true do |t|
    t.string   "name"
    t.string   "type_desc"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tmp_lat_longs", :force => true do |t|
    t.decimal  "lat",        :precision => 12, :scale => 4
    t.decimal  "long",       :precision => 12, :scale => 4
    t.string   "type"
    t.integer  "keyval"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "provider"
    t.string   "uid"
    t.string   "access_token"
    t.boolean  "person_populated"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "ymddates", :force => true do |t|
    t.integer  "year"
    t.integer  "month"
    t.integer  "day"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
