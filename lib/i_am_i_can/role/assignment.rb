module IAmICan
  module Role
    module Assignment
      def becomes_a *roles, which_can: [ ], obj: nil,
                    _d: i_am_i_can.auto_definition,
                    auto_definition: _d || which_can.present?,
                    save: true
        self.class.have_roles *roles, which_can: which_can, obj: obj if auto_definition
        run_callbacks(:role_assign) do
          _roles_assignment(roles, save)
        end
      end

      def is_a_temporary *roles, **options
        becomes_a *roles, save: false, **options
      end

      def falls_from *roles, saved: true
        run_callbacks(:cancel_role_assign) do
          _roles_assignment(:cancel, roles, saved)
        end
      end

      def is_not_a_temporary *roles
        falls_from *roles, saved: false
      end

      def is_only_a *roles
        run_callbacks(:role_update) do
          _roles_assignment(:replace, roles, true)
        end
      end

      %i[ is is_a is_a_role is_roles has_role has_roles role_is role_are ].each { |aname| alias_method aname, :becomes_a }
      %i[ is_not_a will_not_be removes_role leaves has_not_role has_not_roles ].each { |aname| alias_method aname, :falls_from }
      %i[ currently_is_a ].each { |aname| alias_method aname, :is_only_a }

      def _roles_assignment(action = :assign, roles, save)
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
