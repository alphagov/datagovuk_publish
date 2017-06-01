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

ActiveRecord::Schema.define(version: 20170601085954) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "datafiles", force: :cascade do |t|
    t.string "name"
    t.text "url"
    t.string "format"
    t.integer "size"
    t.integer "dataset_id"
    t.date "start_date"
    t.date "end_date"
    t.integer "month"
    t.integer "year"
    t.integer "quarter"
    t.boolean "broken"
    t.datetime "last_check"
    t.boolean "documentation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "datasets", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.string "summary"
    t.text "description"
    t.string "dataset_type"
    t.integer "organisation_id"
    t.string "licence"
    t.text "licence_other"
    t.string "location1"
    t.string "location2"
    t.string "location3"
    t.text "frequency"
    t.integer "creator_id"
    t.integer "owner_id"
    t.boolean "published"
    t.datetime "published_date"
    t.boolean "harvested"
    t.text "legacy_metadata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "inspire_datasets", force: :cascade do |t|
    t.string "bbox_east_long"
    t.string "bbox_west_long"
    t.string "bbox_north_lat"
    t.string "bbox_south_lat"
    t.text "coupled_resource"
    t.text "dataset_reference_date"
    t.string "frequency_of_update"
    t.string "guid"
    t.text "harvest_object_id"
    t.text "harvest_source_reference"
    t.text "import_source"
    t.string "metadata_date"
    t.string "metadata_language"
    t.text "provider"
    t.string "resource_type"
    t.text "responsible_party"
    t.text "spatial"
    t.string "spatial_data_service_type"
    t.string "spatial_reference_system"
    t.bigint "dataset_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dataset_id"], name: "index_inspire_datasets_on_dataset_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.string "location_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisation_statistics", force: :cascade do |t|
    t.string "organisation_name", limit: 64
    t.string "dataset_title", limit: 256
    t.string "subject_title", limit: 64, default: "Downloads"
    t.integer "value", default: 0
    t.string "direction", limit: 4
    t.string "since", limit: 20
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "organisations", force: :cascade do |t|
    t.string "name"
    t.string "title"
    t.text "description"
    t.string "abbreviation"
    t.string "replace_by"
    t.string "contact_email"
    t.string "contact_phone"
    t.string "contact_name"
    t.string "foi_email"
    t.string "foi_phone"
    t.string "foi_name"
    t.string "foi_web"
    t.string "category"
    t.integer "organisation_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "publishing_users", force: :cascade do |t|
    t.string "apikey", limit: 64
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "primary_organisation"
    t.index ["email"], name: "index_publishing_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_publishing_users_on_reset_password_token", unique: true
  end

  add_foreign_key "inspire_datasets", "datasets"
end
