require 'active_record'
require 'active_support/core_ext/object/inclusion'

require 'i_am_i_can/version'
require 'i_am_i_can/has_an_array_of'
require 'i_am_i_can/config'
require 'i_am_i_can/role'
require 'i_am_i_can/am'
require 'i_am_i_can/permission'

module IAmICan
  include HasAnArrayOf

  def act_as_i_am_i_can **options
    cattr_accessor(:ii_config) { IAmICan::Config.new(model: self.name, **options) }

    extend  IAmICan::Role
    delegate :local_roles, to: self, prefix: :model

    include IAmICan::Am
    include IAmICan::Permission

    has_an_array_of :roles,
                    model: options[:role_model] || 'UserRole',
                    prefix: :stored, attrs: [:name], located_by: :name
    "#{name}RoleGroup".constantize
        .has_an_array_of :members,
                         model: options[:role_group_model] || 'UserRole',
                         located_by: :name
  end

  class Error < StandardError;          end
  class VerificationFailed < Error;     end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.extend IAmICan
