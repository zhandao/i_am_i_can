class UserRole < ActiveRecord::Base
  has_and_belongs_to_many :related_users,
                          join_table: 'users_and_user_roles',
                          foreign_key: 'user_id',
                          association_foreign_key: 'user_role_id'
  has_and_belongs_to_many :stored_permissions,
                          join_table: 'user_roles_and_user_permissions',
                          foreign_key: 'user_permission_id',
                          class_name: 'UserPermission',
                          association_foreign_key: 'user_role_id'

  default_scope { includes(:stored_permissions) }

  def self.related_users
    i_am_i_can.subject_model.with_roles.where(user_roles: { id: self.ids })
  end

  def self.related_role_groups
    i_am_i_can.role_group_model.where(user_roles: { id: self.ids })
  end

  # TODO
  def self.stored_permissions
    i_am_i_can.permission_model.with_roles.where(user_roles: { id: self.ids })
  end

  def self.stored_permission_names
    all.flat_map { |user| user.stored_permission_names }.uniq.map(&:to_sym)
  end

  def stored_permission_names
    stored_permissions.map(&:name)
  end

  def stored_permissions_add(check_size: nil, **condition)
    permissions = i_am_i_can.permission_model.where(condition)
    ids = permissions.pluck(:id)
    # will return false if it does nothing
    return false if ids.blank? || (check_size && ids != check_size)
    stored_permissions << permissions
  end

  def stored_permissions_rmv(check_size: nil, **condition)
    permissions = i_am_i_can.permission_model.where(condition)
    ids = permissions.pluck(:id)
    # will return false if it does nothing
    return false if ids.blank? || (check_size && ids != check_size)
    stored_permissions.destroy(permissions)
  end
end
