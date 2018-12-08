module IAmICan
  module Permission
    module Assignment
      def can *actions, resource: nil, obj: resource,
              _d: i_am_i_can.auto_definition, auto_definition: _d
        self.class.have_permissions *actions, obj: obj if auto_definition
        run_callbacks(:permission_assign) do
          _permissions_assignment(actions, obj)
        end
      end

      alias has_permission can

      def cannot *actions, resource: nil, obj: resource
        run_callbacks(:cancel_permission_assign) do
          _permissions_assignment(:cancel, actions, obj)
        end
      end

      alias is_not_allowed_to cannot

      def can_only *actions, resource: nil, obj: resource
        run_callbacks(:permission_update) do
          _permissions_assignment(:replace, actions, obj)
        end
      end

      def _permissions_assignment(action = :assign, actions, obj)
        permissions = actions.product(Array[obj]).map { |(p, o)| { action: p, **deconstruct_obj(o) } }
        assignment = _stored_permissions_exec(action,
                                              permissions.reduce({ }) { |a, b| a.merge(b) { |_, x, y| [x, y] } })
        ResultOf.permission assignment, i_am_i_can, given: [[], permissions.map { |pms| pms.values.compact.join('_').to_sym }]
      end
    end
  end
end
