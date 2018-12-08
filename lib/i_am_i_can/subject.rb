require 'i_am_i_can/subject/role_querying'
require 'i_am_i_can/subject/permission_querying'

module IAmICan
  module Subject
    extend ActiveSupport::Concern

    class_methods do
    end

    included do
      define_model_callbacks :role_assign, :cancel_role_assign, :role_update
    end
  end
end
