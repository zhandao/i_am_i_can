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

      def _permissions_assignment(exec = :assign, actions, obj)
        if actions.tap(&:flatten!).first.is_a?(i_am_i_can.permission_model)
          exec_arg, names = actions, actions.map(&:name)
        else
          objs = obj ? Array(obj) : [nil]
          permissions = actions.product(objs).map { |(p, o)| { action: p, **deconstruct_obj(o) }.values }
          exec_arg = { action: permissions.map(&:first).uniq, obj_type: permissions.map { |v| v[1] }.uniq, obj_id: permissions.map(&:last).uniq }
          names = permissions.map { |pms| pms.compact.join('_').to_sym }
        end

        assignment = _stored_permissions_exec(exec, exec_arg)
        ResultOf.permission assignment, i_am_i_can, given: [[], names]
      end
    end
  end
end
