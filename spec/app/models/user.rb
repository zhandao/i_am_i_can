class User < ActiveRecord::Base
  act_as_subject

  has_and_belongs_to_many :stored_roles,
                          join_table: 'users_and_user_roles',
                          foreign_key: 'user_role_id',
                          class_name: 'UserRole',
                          association_foreign_key: 'user_id'

  scope :with_roles, -> { includes(:stored_roles) }

  def self.stored_role_names
    all.with_roles.flat_map { |user| user.stored_role_names }.uniq.map(&:to_sym)
  end

  def stored_role_names
    stored_roles.pluck(:name).map(&:to_sym)
  end

  def stored_roles_add(locate_vals = nil, check_size: nil, **condition)
    condition = { name: locate_vals } if locate_vals
    records = i_am_i_can.role_model.where(condition).where.not(id: stored_roles.ids)
    # will return false if it does nothing
    return false if records.blank? || (check_size && records.count != check_size)
    stored_roles << records
  end

  def stored_roles_rmv(locate_vals = nil, check_size: nil, **condition)
    condition = { name: locate_vals } if locate_vals
    roles = i_am_i_can.role_model.where(id: stored_roles.ids, **condition)
    # will return false if it does nothing
    return false if roles.blank? || (check_size && roles.count != check_size)
    stored_roles.destroy(roles)
  end
end
