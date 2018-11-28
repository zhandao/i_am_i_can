require 'i_am_i_can/subject/role_querying'
require 'i_am_i_can/subject/permission_querying'

module IAmICan
  module Subject
    extend ActiveSupport::Concern

    class_methods do
      def members_of_role_group name
        i_am_i_can.role_group_model.find_by!(name: name)._roles.names.sort
      end

      def defined_roles
        i_am_i_can.role_model.all
      end

      # TODO
      def defined_role_groups
        i_am_i_can.role_group_model.all.map { |group| [ group.name.to_sym, group._roles.names.map(&:to_sym).sort ] }.to_h
      end
    end

    included do
    end
  end
end
