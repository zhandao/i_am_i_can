module IAmICan
  module RoleGroup
    module Definition
      def group_roles *members, by_name:, which_can: [ ], obj: nil
        group = (i = i_am_i_can).role_group_model.where(name: by_name).first_or_create
        instances, names = Role.extract(members, i)
        assignment = group._members_exec(:assignment, instances, name: names)
        ResultOf.members assignment, i, given: [instances, names]
      end

      %i[ group_role groups_role groups_roles ].each { |aname| alias_method aname, :group_roles }

      def remove_roles *members, from: nil
        # TODO
      end

      def have_and_group_roles *members, by_name:
        have_roles *members
        group_roles *members, by_name: by_name
      end

      alias has_and_groups_roles have_and_group_roles
    end
  end
end
