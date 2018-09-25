require 'i_am_i_can/role/helpers'

module IAmICan
  module Role
    module Assignment
      include Helpers::Ins

      def becomes_a *roles, which_can: [ ], obj: nil, auto_define_before: ii_config.auto_define_before, save: ii_config.default_save
        should_define_role = which_can.present? || auto_define_before
        self.class.have_roles *roles, which_can: which_can, obj: obj, save: save if should_define_role
        failed_items = [ ]

        roles.each do |role|
          if save
            failed_items << role unless stored_roles_add(role)
          else
            next failed_items << role unless role.in?(defined_roles.keys)
            local_role_names << role unless role.in?(local_role_names)
          end
        end

        _role_assignment_result(roles, failed_items)
      end

      alias is        becomes_a
      alias is_roles  becomes_a
      alias is_a_role becomes_a
      alias role_is   becomes_a
      alias roles_are becomes_a
      alias has_roles becomes_a
      alias has_role  becomes_a

      def temporarily_is *roles, **options
        becomes_a *roles, save: false, **options
      end

      def is_not_a *roles, save: ii_config.default_save
        #
      end

      alias has_not_role  is_not_a
      alias has_not_roles is_not_a

      alias locally_is temporarily_is

      def local_role_names
        @local_role_names ||= [ ]
      end

      def local_roles
        defined_local_roles.slice(*local_role_names)
      end

      def roles
        local_role_names + stored_role_names
      end

      alias role_names roles
    end
  end
end
