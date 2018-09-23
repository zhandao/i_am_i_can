require 'active_record'
require 'active_support/core_ext/object/inclusion'
require 'active_support/core_ext/hash/deep_merge'

require 'i_am_i_can/version'
require 'i_am_i_can/has_an_array_of'
require 'i_am_i_can/config'
require 'i_am_i_can/role'
require 'i_am_i_can/am'
require 'i_am_i_can/permission/owner'
require 'i_am_i_can/permission'
require 'i_am_i_can/can'

module IAmICan
  include HasAnArrayOf

  def act_as_i_am_i_can role_model: "#{name}Role".constantize,
                        role_group_model: "#{name}RoleGroup".constantize,
                        permission_model: "#{name}Permission".constantize,
                        auto_define_before: false, strict_mode: false, **options
    cattr_accessor :ii_config do
      IAmICan::Config.new(
          role_model: role_model, role_group_model: role_group_model, permission_model: permission_model,
          auto_define_before: auto_define_before, strict_mode: strict_mode, model: self
      )
    end
    role_model.cattr_accessor(:config) { ii_config }
    role_group_model.cattr_accessor(:config) { ii_config }

    extend  IAmICan::Role
    delegate :local_roles, :stored_roles, :roles, to: self, prefix: :model
    include IAmICan::Am

    role_model.extend IAmICan::Permission::Owner
    role_group_model.extend IAmICan::Permission::Owner
    permission_model.extend IAmICan::Permission
    include IAmICan::Can

    opts = {
        attrs: { name: :to_sym },
        located_by: :name,
        prefix: :stored,
        cache_expires_in: options[:cache_expires_in] || 15.minutes
    }
                self.has_an_array_of :roles, model: role_model.name, for_related_name: 'user', **opts
    role_group_model.has_an_array_of :members, model: role_model.name, for_related_name: 'user', **opts.except(:prefix)
          role_model.has_an_array_of :permissions, model: permission_model.name, for_related_name: 'role', **opts.except(:attrs, :located_by)
    role_group_model.has_an_array_of :permissions, model: permission_model.name, for_related_name: 'role_group', **opts.except(:attrs, :located_by)
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.extend IAmICan
