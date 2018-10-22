class UserRoleGroup < ActiveRecord::Base
  has_and_belongs_to_many :stored_permissions,
                          join_table: 'user_role_groups_and_user_permissions', foreign_key: 'user_permission_id', class_name: 'UserPermission', association_foreign_key: 'user_role_group_id'

  has_and_belongs_to_many :members,
                          join_table: 'user_role_groups_and_user_roles', foreign_key: 'user_role_id', class_name: 'UserRole', association_foreign_key: 'user_role_group_id'

  act_as_role_group
end
