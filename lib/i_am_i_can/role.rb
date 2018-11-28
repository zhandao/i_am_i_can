require 'i_am_i_can/role/definition'
require 'i_am_i_can/role/assignment'
require 'i_am_i_can/role_group/definition'
require 'i_am_i_can/role_group/assignment'

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
      # def attributes
      #   super.symbolize_keys
      # end

      # `can? :manage, User` / `can? :manage, obj: User`
      def can? pred, o = nil, obj: o
        _permissions.matched?(pred, obj)
      end
    end
  end
end
