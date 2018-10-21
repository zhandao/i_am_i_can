require 'active_record'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/hash/deep_merge'

require 'i_am_i_can/version'
require 'i_am_i_can/configurable'
require 'i_am_i_can/role/definition'
require 'i_am_i_can/role/assignment'
require 'i_am_i_can/permission'
require 'i_am_i_can/permission/definition'
require 'i_am_i_can/permission/assignment'
require 'i_am_i_can/subject/role_querying'
require 'i_am_i_can/subject/permission_querying'

module IAmICan
  def act_as_subject
    extend  IAmICan::Role::Definition
    include IAmICan::Role::Assignment
    include IAmICan::Subject::RoleQuerying

     i_am_i_can.permission_model.extend  IAmICan::Permission
           i_am_i_can.role_model.extend  IAmICan::Permission::Definition
           i_am_i_can.role_model.include IAmICan::Permission::Assignment
    i_am_i_can.role_group_model&.extend  IAmICan::Permission::Definition
    i_am_i_can.role_group_model&.include IAmICan::Permission::Assignment
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

  def act_as_permission_source
    #
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.include IAmICan::Configurable
ActiveRecord::Base.extend  IAmICan

