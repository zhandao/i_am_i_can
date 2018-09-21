require 'active_record'
require 'active_support/core_ext/object/inclusion'

require 'i_am_i_can/version'
require 'i_am_i_can/has_an_array_of'
require 'i_am_i_can/config'
require 'i_am_i_can/role'
require 'i_am_i_can/am'
require 'i_am_i_can/role/permission'
require 'i_am_i_can/can'
require 'i_am_i_can/permission'

module IAmICan
  include HasAnArrayOf

  def act_as_i_am_i_can role_model: "#{name}Role".constantize,
                        role_group_model: "#{name}RoleGroup".constantize,
                        permission_model: "#{name}Permission".constantize,
                        **options
    options = local_variables.map { |v| [v, binding.instance_eval(v.to_s)] }.to_h
    cattr_accessor(:ii_config) { IAmICan::Config.new(options) }

    extend  IAmICan::Role
    delegate :local_roles, to: self, prefix: :model
    include IAmICan::Am

    role_model.include IAmICan::Role::Permission
    permission_model.include IAmICan::Permission
    include IAmICan::Can

    array_assoc_opts = {
        prefix: :stored,
        attrs: [:name],
        located_by: :name,
        cache_expires_in: options[:cache_expires_in] || 15.minutes
    }
    has_an_array_of :roles, model: role_model.name, **array_assoc_opts
    role_group_model.has_an_array_of :members, model: role_group_model.name, **array_assoc_opts
    role_model.has_an_array_of :permissions, model: permission_model.name, **array_assoc_opts
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.extend IAmICan
