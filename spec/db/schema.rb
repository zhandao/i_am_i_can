ActiveRecord::Schema.define do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "users", force: :cascade do |t|
    t.string "name"#, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.string "name", null: false
    t.string "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_user_roles_on_name", unique: true
  end

  create_table "user_role_groups", force: :cascade do |t|
    t.string "name", null: false
    t.integer "member_ids", default: [ ], array: true
    # t.integer "permission_ids", default: [ ], array: true
    t.string "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_user_role_groups_on_name", unique: true
  end

  create_table "user_permissions", force: :cascade do |t|
    t.string "pred", null: false
    t.string "obj_type"
    t.integer "obj_id"
    t.string "remarks"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["pred", "obj_type", "obj_id"], name: "permission_unique_index", unique: true
    # t.index ["obj_type", "obj_id"], name: "index_permissions_on_source_type_and_source_id"
  end

  create_table "resources", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users_and_user_roles", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "user_role_id", null: false
    t.index ["user_id"], name: 'user_role_index1'
    # t.index ["user_role_id"], name: 'user_role_index2'
    t.index ["user_id", "user_role_id"], unique: true, name: 'user_role_uniq'
  end

  create_table "user_role_groups_and_user_roles", id: false, force: :cascade do |t|
    t.bigint "user_role_group_id", null: false
    t.bigint "user_role_id", null: false
    t.index ["user_role_group_id"], name: 'users_group_role_index1'
    # t.index ["user_role_id"], name: 'users_group_role_index2'
    t.index ["user_role_group_id", "user_role_id"], unique: true, name: 'users_group_role_uniq'
  end

  create_table "user_roles_and_user_permissions", id: false, force: :cascade do |t|
    t.bigint "user_role_id", null: false
    t.bigint "user_permission_id", null: false
    t.index ["user_role_id"], name: 'users_role_permission_index1'
    # t.index ["user_permission_id"], name: 'users_role_permission_index2'
    t.index ["user_role_id", "user_permission_id"], unique: true, name: 'users_role_permission_uniq'
  end

  create_table "user_role_groups_and_user_permissions", id: false, force: :cascade do |t|
    t.bigint "user_role_group_id", null: false
    t.bigint "user_permission_id", null: false
    t.index ["user_role_group_id"], name: 'users_group_permission_index1'
    # t.index ["user_permission_id"], name: 'users_group_permission_index2'
    t.index ["user_role_group_id", "user_permission_id"], unique: true, name: 'users_group_permission_uniq'
  end
end
