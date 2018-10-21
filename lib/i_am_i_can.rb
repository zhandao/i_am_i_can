require 'active_record'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/hash/deep_merge'

require 'i_am_i_can/version'
require 'i_am_i_can/config'
require 'i_am_i_can/role/definition'
require 'i_am_i_can/role/assignment'
require 'i_am_i_can/permission'
require 'i_am_i_can/permission/definition'
require 'i_am_i_can/permission/assignment'
require 'i_am_i_can/subject/role_querying'
require 'i_am_i_can/subject/permission_querying'

module IAmICan
  def act_as_i_am_i_can role_model: "#{name}Role".constantize,
                        role_group_model: ("#{name}RoleGroup".constantize rescue nil),
                        permission_model: "#{name}Permission".constantize, **options
    cattr_accessor :ii_config do
      IAmICan::Config.new(
          role_model: role_model,
          role_group_model: role_group_model,
          permission_model: permission_model,
          subject_model: self, **options
      )
    end
    role_model.cattr_accessor(:config) { ii_config }
    role_group_model&.cattr_accessor(:config) { ii_config }

    extend  IAmICan::Role::Definition
    include IAmICan::Role::Assignment
    include IAmICan::Subject::RoleQuerying

     permission_model.extend  IAmICan::Permission
           role_model.extend  IAmICan::Permission::Definition
           role_model.include IAmICan::Permission::Assignment
    role_group_model&.extend  IAmICan::Permission::Definition
    role_group_model&.include IAmICan::Permission::Assignment
                 self.include IAmICan::Subject::PermissionQuerying
  end

  def act_as_role
    #
  end

  def act_as_role_group
    #
  end

  def act_as_permission
    #
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.extend IAmICan
