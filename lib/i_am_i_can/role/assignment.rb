module IAmICan
  module Role
    module Assignment
      def becomes_a *roles, which_can: [ ], obj: nil,
                    _d: i_am_i_can.auto_definition,
                    auto_definition: _d || which_can.present?,
                    save: i_am_i_can.disable_temporary || i_am_i_can.saved_by_default
        self.class.have_roles *roles, which_can: which_can, obj: obj, save: save if auto_definition
        _roles_assignment(roles, save)
      end

      %i[ is is_a_role is_roles has_role has_roles role_is role_are ].each { |aname| alias_method aname, :becomes_a }

      def is_a_temporary *roles, **options
        becomes_a *roles, save: false, **options
      end

      def falls_from *roles, saved: i_am_i_can.disable_temporary || i_am_i_can.saved_by_default
        _roles_assignment(:cancel, roles, saved)
      end

      %i[ is_not_a will_not_be removes_role leaves has_not_role has_not_roles ].each { |aname| alias_method aname, :falls_from }

      def is_not_a_temporary *roles
        falls_from *roles, saved: false
      end

      def _roles_assignment(action = :assignment, roles, save)
        instances, names = Role.extract(roles, i_am_i_can)
        if save
          assignment = _stored_roles_exec(action, instances, name: names)
        else
          to_be_assigned_names = (instances.map(&:name).map(&:to_sym) + names).uniq
          assignment = _temporary_roles_exec(action, to_be_assigned_names)
        end

        ResultOf.role assignment, i_am_i_can, given: [instances, names]
      end
    end
  end
end
