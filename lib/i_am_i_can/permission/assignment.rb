require 'i_am_i_can/permission/methods'

module IAmICan
  module Permission
    module Assignment
      include Methods::Ins

      def can *preds,
              resource: nil, obj: resource,
              _d: i_am_i_can.auto_definition, auto_definition: _d
        self.class.have_permissions *preds, obj: obj if auto_definition
        _permissions_assignment(preds, obj)
      end

      alias has_permission can

      def cannot *preds, obj: nil
        _permissions_assignment(:cancel, preds, obj)
      end

      alias is_not_allowed_to cannot

      def _permissions_assignment(action = :assignment, preds, obj)
        permissions = preds.product(Array[obj]).map { |(p, o)| { pred: p, **deconstruct_obj(o) } }
        assignment = _stored_permissions_exec(action, permissions.reduce({ }) { |a, b| a.merge(b) { |_, x, y| [x, y] } })
        ResultOf.permission assignment, i_am_i_can, given: [[], permissions.map { |pms| pms.values.compact.join('_').to_sym }]
      end

      # `can? :manage, User` / `can? :manage, obj: User`
      def can? pred, obj0 = nil, obj: nil
        obj = obj0 || obj
        pms_name = pms_naming(pred, obj)
        pms_matched?(pms_name, in: stored_permission_names)
      end
    end
  end
end
