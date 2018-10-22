class User < ActiveRecord::Base
  has_and_belongs_to_many :stored_roles,
                          join_table: 'users_and_user_roles', foreign_key: 'user_role_id', class_name: 'UserRole', association_foreign_key: 'user_id'

  act_as_subject
end
