require 'active_record'
require 'active_support/core_ext/object/inclusion'

require 'i_am_i_can/version'
require 'i_am_i_can/has_an_array_of'
require 'i_am_i_can/config'
require 'i_am_i_can/role'
require 'i_am_i_can/am'
require 'i_am_i_can/role/permission'
require 'i_am_i_can/can'

module IAmICan
  include HasAnArrayOf

  def act_as_i_am_i_can **options
    role_model = "#{name}Role".constantize
    role_group_model = "#{name}RoleGroup".constantize

    cattr_accessor(:ii_config) { IAmICan::Config.new(model: self.name, **options) }

    extend  IAmICan::Role
    delegate :local_roles, to: self, prefix: :model
    include IAmICan::Am
    
    role_model.include IAmICan::Role::Permission
    include IAmICan::Can

    array_assoc_opts = {
        prefix: :stored,
        attrs: [:name],
        located_by: :name,
        cache_expires_in: options[:cache_expires_in] || 15.minutes
    }
    has_an_array_of :roles, model: options[:role_model] || 'UserRole', **array_assoc_opts
    role_group_model.has_an_array_of :members, model: options[:role_group_model] || 'UserRole', **array_assoc_opts
    role_model.has_an_array_of :permissions, model: options[:permission_model] || 'UserPermission', **array_assoc_opts
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.extend IAmICan
