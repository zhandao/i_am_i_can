require 'active_record'
require 'active_support/core_ext/object/inclusion'

require 'i_am_i_can/version'
require 'i_am_i_can/role'
require 'i_am_i_can/am'
require 'i_am_i_can/permission'

module IAmICan
  def act_as_i_am_i_can
    extend  IAmICan::Role
    delegate :roles, to: self, prefix: :model

    include IAmICan::Am
    include IAmICan::Permission
  end

  class Error < StandardError; end
  class VerificationFailed < Error; end
  class InsufficientPermission < Error; end
end

ActiveRecord::Base.extend IAmICan
