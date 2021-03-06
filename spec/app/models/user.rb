class User < ActiveRecord::Base
  has_and_belongs_to_many :stored_roles, -> { where('expire_at IS NULL OR expire_at > ?', Time.current) },
                          join_table: 'users_and_user_roles', foreign_key: 'user_id',
                          class_name: 'UserRole', association_foreign_key: 'user_role_id'

  has_many_temporary_roles

  acts_as_subject
end
