require 'i_am_i_can/permission/methods'

module IAmICan
  module Permission
    module Assignment
      include Methods::Ins

      def can *preds,
              resource: nil, obj: resource,
              strict_mode: false,
              _d: i_am_i_can.auto_definition, auto_definition: _d
        self.class.have_permissions *preds, obj: obj if auto_definition

        permissions = preds.product(Array[obj]).map { |(p, o)| { pred: p, **deconstruct_obj(o) } }
        assignment = _stored_permissions_add(permissions.reduce({ }) { |a, b| a.merge(b) { |_, x, y| [x, y] } })
        ResultOf.permission assignment, i_am_i_can, given: [[], permissions.map { |pms| pms.values.compact.join('_').to_sym }]
      end

      alias has_permission can

      def cannot *preds, obj: nil
        not_defined_items = [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          next if _stored_permissions_rmv(pred: pred, **deconstruct_obj(obj)).present?
          not_defined_items << pms_name
        end

        _pms_assignment_result(preds, obj, not_defined_items)
      end

      alias is_not_allowed_to cannot

      # `can? :manage, User` / `can? :manage, obj: User`
      def can? pred, obj0 = nil, obj: nil
        obj = obj0 || obj
        pms_name = pms_naming(pred, obj)
        pms_matched?(pms_name, in: stored_permission_names)
      end
    end
  end
end
