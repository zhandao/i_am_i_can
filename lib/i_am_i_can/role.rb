# frozen_string_literal: true

require 'i_am_i_can/role/definition'
require 'i_am_i_can/role/assignment'
require 'i_am_i_can/role/grouping'
require 'i_am_i_can/role_group/definition'

module IAmICan
  module Role
    extend ActiveSupport::Concern

    class_methods do
      def which(name:, **conditions)
        find_by!(name: name, **conditions)
      end

      def names
        self.pluck(:name).map(&:to_sym)
      end
    end

    included do
      define_model_callbacks :permission_assign, :cancel_permission_assign, :permission_update

      # `can? :manage, User` / `can? :manage, obj: User`
      def can? action, o = nil, obj: o
        _permissions.matched?(action, obj)
      end
    end
  end
end
