require 'i_am_i_can/subject/role_querying'
require 'i_am_i_can/subject/permission_querying'

module IAmICan
  module Subject
    extend ActiveSupport::Concern

    class_methods do
      # permission assignment locally for local role
      # User.temporary_role_which(name: :admin).can: :fly
      #   same effect to: UserRole.new(name: :admin).temporarily_can :fly
      def temporary_role_which(name:)
        i_am_i_can.role_model.new(name: name)
      end

      def members_of_role_group name
        i_am_i_can.role_group_model.find_by!(name: name).member_names.sort
      end

      def defined_roles
        i_am_i_can.role_model.all
      end

      def defined_role_names
        i_am_i_can.role_model.all.names
      end

      # TODO
      def defined_role_groups
        i_am_i_can.role_group_model.all.map { |group| [ group.name.to_sym, group.member_names.map(&:to_sym).sort ] }.to_h
      end
    end

    included do
    end
  end
end
