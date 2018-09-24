require 'active_record'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/hash/deep_merge'

require 'i_am_i_can/version'
require 'i_am_i_can/has_an_array_of'
require 'i_am_i_can/config'
require 'i_am_i_can/role/definition'
require 'i_am_i_can/role/assignment'
require 'i_am_i_can/permission'
require 'i_am_i_can/permission/definition'
require 'i_am_i_can/permission/assignment'
require 'i_am_i_can/subject/role_querying'
require 'i_am_i_can/subject/permission_querying'

module IAmICan
  include HasAnArrayOf

  def act_as_i_am_i_can role_model: "#{name}Role".constantize,
                        role_group_model: "#{name}RoleGroup".constantize,
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
    role_group_model.cattr_accessor(:config) { ii_config }

    extend  IAmICan::Role::Definition
    include IAmICan::Role::Assignment
    include IAmICan::Subject::RoleQuerying

    permission_model.extend  IAmICan::Permission
          role_model.extend  IAmICan::Permission::Definition
          role_model.include IAmICan::Permission::Assignment
    role_group_model.extend  IAmICan::Permission::Definition
    role_group_model.include IAmICan::Permission::Assignment
                self.include IAmICan::Subject::PermissionQuerying

    opts = {
        attrs: { name: :to_sym },
        located_by: :name,
        prefix: :stored,
        cache_expires_in: options[:cache_expires_in] || 15.minutes
    }
                self.has_an_array_of :roles, model: role_model.name, for_related_name: name.underscore, **opts
    role_group_model.has_an_array_of :members, model: role_model.name, for_related_name: 'role_group', **opts.except(:prefix)
          role_model.has_an_array_of :permissions, model: permission_model.name, for_related_name: 'role', **opts.except(:attrs, :located_by)
    role_group_model.has_an_array_of :permissions, model: permission_model.name, for_related_name: 'role_group', **opts.except(:attrs, :located_by)
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.extend IAmICan
