require 'i_am_i_can/version'
require 'i_am_i_can/role'
require 'i_am_i_can/permission'

module IAmICan
  def self.included(base)
    base.include IAmICan::Role
    base.include IAmICan::Permission
  end
end
