ActiveRecord::Schema.define do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "name"#, null: false
    t.integer "role_ids", default: [ ], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "desc"
    t.integer "permission_ids", default: [ ], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_user_roles_on_name", unique: true
  end

  create_table "user_role_groups", force: :cascade do |t|
    t.string "name", null: false
    t.integer "member_ids", default: [ ], array: true
    t.integer "permission_ids", default: [ ], array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_user_role_groups_on_name", unique: true
  end

  create_table "user_permissions", force: :cascade do |t|
    t.string "pred", null: false
    t.string "obj_type"
    t.integer "obj_id"
    t.string "desc"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pred", "obj_type", "obj_id"], name: "permission_unique_index", unique: true
    # t.index ["obj_type", "obj_id"], name: "index_permissions_on_source_type_and_source_id"
  end
end
