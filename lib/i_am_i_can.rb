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
    include IAmICan::Subject::PermissionQuerying
  end

  def act_as_role
    extend  IAmICan::Permission::Definition
    include IAmICan::Permission::Assignment
  end

  def act_as_role_group
    extend  IAmICan::Permission::Definition
    include IAmICan::Permission::Assignment
  end

  def act_as_permission
    extend IAmICan::Permission
  end

  def act_as_allowed_source
    #
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.include IAmICan::Configurable
ActiveRecord::Base.extend  IAmICan

