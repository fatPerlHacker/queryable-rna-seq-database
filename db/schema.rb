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

ActiveRecord::Schema.define(:version => 20121007023055) do

  create_table "job_statuses", :id => false, :force => true do |t|
    t.string   "name",        :null => false
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "jobs", :force => true do |t|
    t.string   "job_status",             :null => false
    t.string   "current_program_status", :null => false
    t.string   "eid_of_owner",           :null => false
    t.integer  "workflow_steps_id",      :null => false
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
  end

  create_table "program_statuses", :id => false, :force => true do |t|
    t.string   "name",        :null => false
    t.string   "description", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "programs", :id => false, :force => true do |t|
    t.string   "internal_name", :null => false
    t.string   "display_name"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "users", :id => false, :force => true do |t|
    t.string   "eid",        :null => false
    t.string   "email",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "workflow_steps", :force => true do |t|
    t.integer  "workflow_id"
    t.string   "program_internal_name"
    t.integer  "step"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
  end

  create_table "workflows", :force => true do |t|
    t.string   "display_name"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end
