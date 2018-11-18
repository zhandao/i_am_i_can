require 'i_am_i_can/permission/methods'

module IAmICan
  module Permission
    module Assignment
      include Methods::Ins

      def can *preds,
              resource: nil, obj: resource,
              strict_mode: false,
              _d: i_am_i_can.auto_definition, auto_definition: _d
        return temporarily_can(*preds, obj: obj, strict_mode: strict_mode, auto_definition: auto_definition) if new_record?
        self.class.have_permissions *preds, obj: obj if auto_definition

        permissions = preds.product(Array[obj]).map { |(p, o)| { pred: p, **deconstruct_obj(o) } }
        assignment = _stored_permissions_add(permissions.reduce({ }) { |a, b| a.merge(b) { |_, x, y| [x, y] } })
        ResultOf.permission assignment, i_am_i_can, given: [[], permissions.map { |pms| pms.values.compact.join('_').to_sym }]
      end

      alias has_permission can

      def temporarily_can *preds, obj: nil, strict_mode: false, auto_definition: i_am_i_can.auto_definition
        raise Error, "Permission Assignment: local role `#{name}` was not defined" unless i_am_i_can.subject_model.defined_temporary_roles.key?(self.name.to_sym)
        self.class.have_permissions *preds, obj: obj, save: false if auto_definition
        # not_defined_items, covered_items = [ ], [ ]
        #
        # preds.each do |pred|
        #   pms_name = pms_naming(pred, obj)
        #   next not_defined_items << pms_name unless pms_name.in?(defined_permission_names)
        #   pms_of_defined_local_role(self.name) << pms_name
        # end

        permissions = preds.product(Array[obj]).map { |(p, o)| { pred: p, **deconstruct_obj(o) } }
        names = permissions.map { |pms| pms.values.compact.join('_').to_sym }
        stored = i_am_i_can.permission_model.where(permissions.reduce({ }) { |a, b| a.merge(b) { |_, x, y| [x, y] } })
        tmp = defined_tmp_permissions.where(name: names - stored.names)
        pms_of_defined_local_role(self.name)[:id].concat(stored.ids)
        pms_of_defined_local_role(self.name)[:index].concat(tmp.values)
        assignment = stored.names + tmp.keys
        # _pms_assignment_result(preds, obj, not_defined_items, covered_items, strict_mode)
        ResultOf.permission assignment, i_am_i_can, given: [[], names]
      end

      alias locally_can temporarily_can

      def cannot *preds, obj: nil, saved: true
        not_defined_items = [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          if saved
            next if _stored_permissions_rmv(pred: pred, **deconstruct_obj(obj)).present?
            not_defined_items << pms_name
          else
            next not_defined_items << pms_name unless pms_name.in?(defined_permission_names)
            pms_of_defined_local_role(self.name).delete(pms_name)
          end
        end

        _pms_assignment_result(preds, obj, not_defined_items)
      end

      alias is_not_allowed_to cannot

      # `can? :manage, User` / `can? :manage, obj: User`
      def can? pred, obj0 = nil, obj: nil
        obj = obj0 || obj
        pms_name = pms_naming(pred, obj)
        temporarily_can?(pred, obj) || pms_matched?(pms_name, in: stored_permission_names)
      end

      def temporarily_can? pred, obj
        pms_name = pms_naming(pred, obj)
        pms_matched?(pms_name, in: pms_of_defined_local_role(self.name))
      end

      alias locally_can? temporarily_can?
    end
  end
end
