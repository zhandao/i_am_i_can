class UserPermission < ActiveRecord::Base
  has_and_belongs_to_many :related_roles,
                          join_table: 'user_roles_and_user_permissions', foreign_key: 'user_role_id', class_name: 'UserRole', association_foreign_key: 'user_permission_id'

  has_and_belongs_to_many :related_role_groups,
                          join_table: 'user_role_groups_and_user_permissions', foreign_key: 'user_role_group_id', class_name: 'UserRoleGroup', association_foreign_key: 'user_permission_id'

  act_as_permission
end
