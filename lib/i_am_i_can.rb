require 'active_record'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/hash/deep_merge'

require 'i_am_i_can/version'
require 'i_am_i_can/configurable'
require 'i_am_i_can/reflection'
require 'i_am_i_can/dynamic_generate'
require 'i_am_i_can/role'
require 'i_am_i_can/permission'
require 'i_am_i_can/subject'
require 'i_am_i_can/resource'

module IAmICan
  def acts_as_subject
    i_am_i_can.act = :subject
    include Subject

    extend  Role::Definition
    include Role::Assignment
    include Subject::RoleQuerying
    include Subject::PermissionQuerying

    include Reflection
    instance_exec(%i[ role ], &DynamicGenerate.scopes)
    instance_exec(&DynamicGenerate.class_reflections)
    instance_exec(%w[ role ], &DynamicGenerate.assignment_helpers)
  end

  def acts_as_role
    i_am_i_can.act = :role
    include Role

    extend  Permission::Definition
    include Permission::Assignment

    include Reflection
    instance_exec(%i[ subject role_group permission ], &DynamicGenerate.scopes)
    instance_exec(&DynamicGenerate.class_reflections)
    instance_exec(%w[ permission ], &DynamicGenerate.assignment_helpers)
  end

  def acts_as_role_group
    i_am_i_can.act = :role_group
    include Role

    extend  Permission::Definition
    include Permission::Assignment

    include Reflection
    instance_exec(%i[ permission role ], &DynamicGenerate.scopes)
    instance_exec(&DynamicGenerate.class_reflections)
    instance_exec(%w[ role permission ], &DynamicGenerate.assignment_helpers)
  end

  def acts_as_permission
    i_am_i_can.act = :permission
    include Permission

    include Reflection
    instance_exec(%i[ role role_group ], &DynamicGenerate.scopes)
    instance_exec(&DynamicGenerate.class_reflections)
  end

  def acts_as_allowed_resource
    include Resource
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.include IAmICan::Configurable
ActiveRecord::Base.extend  IAmICan

