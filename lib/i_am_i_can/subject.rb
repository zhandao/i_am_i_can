# frozen_string_literal: true

require 'i_am_i_can/subject/role_querying'
require 'i_am_i_can/subject/permission_querying'

module IAmICan
  module Subject
    extend ActiveSupport::Concern

    class_methods do
    end

    included do
      define_model_callbacks :role_assign, :cancel_role_assign, :role_update

      Object.const_set (role_assoc_class = reflections[__roles].options[:join_table].camelize),
                       Class.new(ActiveRecord::Base)
      has_many :"assoc_with_#{__roles}", -> { where('expire_at IS NULL OR expire_at > ?', Time.current) },
               class_name: role_assoc_class
    end
  end
end
