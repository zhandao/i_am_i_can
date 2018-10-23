require 'i_am_i_can/role/helpers'

module IAmICan
  module Role
    module Assignment
      include Helpers::Ins

      def becomes_a *roles, which_can: [ ], obj: nil, auto_define_before: i_am_i_can.auto_define_before, save: i_am_i_can.default_save
        should_define_role = which_can.present? || auto_define_before
        self.class.have_roles *roles, which_can: which_can, obj: obj, save: save if should_define_role
        failed_items = [ ]

        roles.map(&__role).each do |role|
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
      alias is_a_role becomes_a
      alias is_roles  becomes_a
      alias has_role  becomes_a
      alias has_roles becomes_a
      alias role_is   becomes_a
      alias roles_are becomes_a

      def temporarily_is *roles, **options
        becomes_a *roles, save: false, **options
      end

      alias locally_is temporarily_is

      def falls_from *roles, saved: i_am_i_can.default_save
        failed_items = [ ]

        roles.each do |role|
          if saved
            failed_items << role unless stored_roles_rmv(role)
          else
            next failed_items << role unless role.in?(defined_roles.keys)
            local_role_names.delete(role)
          end
        end

        _role_assignment_result(roles, failed_items)
      end

      alias is_not_a      falls_from
      alias will_not_be   falls_from
      alias removes_role  falls_from
      alias leaves        falls_from
      alias has_not_role  falls_from
      alias has_not_roles falls_from
    end
  end
end
