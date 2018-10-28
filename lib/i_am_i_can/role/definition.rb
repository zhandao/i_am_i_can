require 'i_am_i_can/role/methods'

module IAmICan
  module Role
    module Definition
      include Methods::Cls

      def have_role *roles, save: i_am_i_can.saved_by_default, which_can: [ ], obj: nil
        roles.map!(&:to_sym)
        if save
          definition = _create_roles(roles.map { |role| { name: role } })
        else
          definition = _define_tmp_roles(roles)
        end

        Role.modeling(definition).each { |r| r.can *which_can, obj: obj, auto_definition: true } if which_can.present?
        ResultOf.roles definition, given: roles
      end

      %i[ have_roles has_role has_roles ].each { |aname| alias_method aname, :have_role }

      def declare_role *names, **options
        have_role *names, save: false, **options
      end

      alias declare_roles has_role

      def group_roles *members, by_name:, which_can: [ ], obj: nil
        raise Error, 'Some of members have not been defined' unless (members - i_am_i_can.role_model.all.names).empty?
        raise Error, "Given name #{by_name} has been used by a role" if i_am_i_can.role_model.exists?(name: by_name)
        i_am_i_can.role_group_model.find_or_create_by!(name: by_name)._members_add(name: members)
      end

      %i[ group_role groups_role groups_roles ].each { |aname| alias_method aname, :group_roles }

      def have_and_group_roles *members, by_name:
        have_roles *members
        group_roles *members, by_name: by_name
      end

      alias has_and_groups_roles have_and_group_roles
    end

    def self.modeling(objs)
      return objs if objs.first.is_a?(Configs.take.role_model)
      objs.map { |obj| Configs.take.role_model.new(name: obj) }
    end
  end
end
