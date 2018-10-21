class UserRoleGroup < ActiveRecord::Base
  act_as_role_group

  has_and_belongs_to_many :stored_permissions,
                          join_table: 'user_role_groups_and_user_permissions',
                          foreign_key: 'user_permission_id',
                          class_name: 'UserPermission',
                          association_foreign_key: 'user_role_group_id'
  has_and_belongs_to_many :members,
                          join_table: 'user_role_groups_and_user_roles',
                          foreign_key: 'user_role_id',
                          class_name: 'UserRole',
                          association_foreign_key: 'user_role_group_id'

  default_scope { includes(:members, :stored_permissions) }

  def self.stored_permission_names
    all.flat_map { |user| user.permission_names }.uniq.map(&:to_sym)
  end

  def self.stored_permissions
    i_am_i_can.permission_model.with_role_groups.where(user_role_groups: { id: self.ids })
  end

  def permission_names
    stored_permissions.map(&:name)
  end

  def stored_permissions_add(check_size: nil, **condition)
    records = i_am_i_can.permission_model.where(condition).where.not(id: stored_permissions.ids)
    # will return false if it does nothing
    return false if records.blank? || (check_size && records.count != check_size)
    stored_permissions << records
  end

  def stored_permissions_rmv(check_size: nil, **condition)
    records = i_am_i_can.permission_model.where(id: stored_permissions.ids, **condition)
    # will return false if it does nothing
    return false if records.blank? || (check_size && records.count != check_size)
    stored_permissions.destroy(records)
  end

  def member_names
    members.pluck(:name).map(&:to_sym)
  end

  def members_add(names, check_size: nil)
    records = i_am_i_can.role_model.where(name: names).where.not(id: member_ids)
    # will return false if it does nothing
    return false if records.blank? || (check_size && records.count != check_size)
    members << records
  end

  def members_rmv(names, check_size: nil)
    records = i_am_i_can.role_model.where(id: member_ids, name: names)
    # will return false if it does nothing
    return false if records.blank? || (check_size && records.count != check_size)
    members.destroy(records)
  end
end
