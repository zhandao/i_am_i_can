# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/hash/deep_merge'

require 'i_am_i_can/version'
require 'i_am_i_can/support/association_class_methods'
require 'i_am_i_can/support/configurable'
require 'i_am_i_can/support/reflection'
require 'i_am_i_can/helpers/result_of'
require 'i_am_i_can/helpers/dynamic'
require 'i_am_i_can/role'
require 'i_am_i_can/permission'
require 'i_am_i_can/subject'
require 'i_am_i_can/resource'

module IAmICan
  def acts_as_subject
    i_am_i_can&.act = :subject
    include Reflection
    include Subject

    extend  Role::Definition
    include Role::Assignment
    extend  RoleGroup::Definition
    include Subject::RoleQuerying
    include Subject::PermissionQuerying

    instance_exec(%i[ role ], &Dynamic.scopes)
    instance_exec(&Dynamic.class_reflections)
    instance_exec(%w[ role ], &Dynamic.assignment_helpers)
    instance_exec(%w[ role ], &Dynamic.definition_helpers)
  end

  def acts_as_role
    i_am_i_can&.act = :role
    include Reflection
    include Role

    extend  Permission::Definition
    include Permission::Assignment

    instance_exec(%i[ subject role_group permission ], &Dynamic.scopes)
    instance_exec(&Dynamic.class_reflections)
    instance_exec(%w[ permission ], &Dynamic.assignment_helpers)
    instance_exec(%w[ permission ], &Dynamic.definition_helpers)

    before_create { self.remarks ||= name.to_s.humanize }
    validates :name, uniqueness: true
  end

  def acts_as_role_group
    i_am_i_can&.act = :role_group
    include Reflection
    include Role
    # include RoleGroup

    include Role::Grouping
    extend  Permission::Definition
    include Permission::Assignment

    instance_exec(%i[ permission role ], &Dynamic.scopes)
    instance_exec(&Dynamic.class_reflections)
    instance_exec(%w[ role permission ], &Dynamic.assignment_helpers)
    instance_exec(%w[ permission ], &Dynamic.definition_helpers)

    before_create { self.remarks ||= name.to_s.humanize }
    validates :name, uniqueness: true
  end

  def acts_as_permission
    i_am_i_can&.act = :permission
    include Reflection
    include Permission

    instance_exec(%i[ role role_group ], &Dynamic.scopes)
    instance_exec(&Dynamic.class_reflections)

    before_create { self.remarks ||= name.to_s.humanize }
    validates :action, uniqueness: { scope: %i[ obj_type obj_id ] }
  end

  def acts_as_allowed_resource
    include Resource
  end

  class Error                  < StandardError;  end
  class VerificationFailed     < Error; end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.include IAmICan::Configurable
ActiveRecord::Base.extend  IAmICan::Association_ClassMethods
ActiveRecord::Base.extend  IAmICan

