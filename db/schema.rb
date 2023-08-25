# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_08_23_223902) do
  create_table "big_categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "transaction_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transaction_type_id"], name: "index_big_categories_on_transaction_type_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.string "uid"
    t.integer "user_1_id", null: false
    t.integer "user_2_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_1_id"], name: "index_relationships_on_user_1_id"
    t.index ["user_2_id"], name: "index_relationships_on_user_2_id"
  end

  create_table "small_categories", force: :cascade do |t|
    t.string "name", null: false
    t.integer "big_category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["big_category_id"], name: "index_small_categories_on_big_category_id"
  end

  create_table "transaction_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_transaction_types_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "email"
    t.string "name"
    t.string "image"
    t.integer "relationship_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["relationship_id"], name: "index_users_on_relationship_id"
    t.index ["uid"], name: "index_users_on_uid", unique: true
  end

  add_foreign_key "big_categories", "transaction_types"
  add_foreign_key "relationships", "user_1s"
  add_foreign_key "relationships", "user_2s"
  add_foreign_key "small_categories", "big_categories"
  add_foreign_key "users", "relationships"
end
