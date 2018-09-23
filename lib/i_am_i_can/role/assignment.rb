module IAmICan
  module Role
    module Assignment
      # TODO: cache
      def becomes_a *roles, which_can: [ ], obj: nil, auto_define_before: false, save: true
        should_define_role = which_can.present? || auto_define_before || ii_config.auto_define_before
        self.class.have_roles *roles, which_can: which_can, obj: obj, save: save if should_define_role
        failed_items = [ ]

        roles.each do |role|
          if save
            failed_items << role unless stored_roles_add(role)
          else
            next failed_items << role unless role.in?(model_roles.keys)
            local_roles << role unless role.in?(local_roles)
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

      def temporarily_is *roles
        becomes_a *roles, save: false
      end

      alias locally_is temporarily_is

      def _role_assignment_result(names, failed_items)
        prefix = 'Role Assignment Done'
        fail_msg = prefix + ", but #{failed_items} have not been defined" if failed_items.present?
        raise Error, fail_msg if ii_config.strict_mode && fail_msg
        fail_msg ? fail_msg : prefix
      end

      def local_roles
        @local_roles ||= [ ]
      end

      alias local_role_names local_roles

      def roles
        local_roles + stored_role_names
      end

      alias role_names roles
    end
  end
end
