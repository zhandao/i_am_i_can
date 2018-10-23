require 'i_am_i_can/subject/role_querying'
require 'i_am_i_can/subject/permission_querying'

module IAmICan
  module Subject
    extend ActiveSupport::Concern

    class_methods do
      # permission assignment locally for local role
      # User.local_role_which(name: :admin, can: :fly)
      #   same effect to: UserRole.new(name: :admin).temporarily_can :fly
      def local_role_which(name:, can:, obj: nil, **options)
        i_am_i_can.role_model.new(name: name).temporarily_can *Array(can), obj: obj, **options
      end

      def members_of_role_group name
        i_am_i_can.role_group_model.find_by!(name: name).member_names.sort
      end
    end

    included do
    end
  end
end
