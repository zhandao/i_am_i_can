class UserRole < ActiveRecord::Base
  has_and_belongs_to_many :related_users,
                          join_table: 'users_and_user_roles', foreign_key: 'user_id', class_name: 'User', association_foreign_key: 'user_role_id'

  has_and_belongs_to_many :related_role_groups,
                          join_table: 'user_role_groups_and_user_roles', foreign_key: 'user_role_group_id', class_name: 'UserRoleGroup', association_foreign_key: 'user_role_id'

  has_and_belongs_to_many :permissions,
                          join_table: 'user_roles_and_user_permissions', foreign_key: 'user_permission_id', class_name: 'UserPermission', association_foreign_key: 'user_role_id'

  acts_as_role
end
