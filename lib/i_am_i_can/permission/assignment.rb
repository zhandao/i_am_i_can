require 'i_am_i_can/permission/helpers'

module IAmICan
  module Permission
    module Assignment
      include Helpers::Ins

      # permission assignment for stored role
      def can *preds, obj: nil, strict_mode: false, auto_define_before: i_am_i_can.auto_define_before
        self.class.have_permissions *preds, obj: obj if auto_define_before
        not_defined_items, covered_items = [ ], [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          covered_items << pms_name if pms_matched?(pms_name, in: stored_permission_names)
          not_defined_items << pms_name unless stored_permissions_add(pred: pred, **deconstruct_obj(obj))
        end

        _pms_assignment_result(preds, obj, not_defined_items, covered_items, strict_mode)
      end

      alias has_permission can

      def temporarily_can *preds, obj: nil, strict_mode: false, auto_define_before: i_am_i_can.auto_define_before
        raise Error, "Permission Assignment: local role `#{name}` was not defined" unless i_am_i_can.subject_model.defined_local_roles.key?(self.name.to_sym)
        self.class.have_permissions *preds, obj: obj, save: false if auto_define_before
        not_defined_items, covered_items = [ ], [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          next not_defined_items << pms_name unless pms_name.in?(defined_permissions.keys)
          covered_items << pms_name if pms_matched?(pms_name, in: pms_of_defined_local_role(self.name))
          pms_of_defined_local_role(self.name) << pms_name
        end

        _pms_assignment_result(preds, obj, not_defined_items, covered_items, strict_mode)
      end

      alias locally_can temporarily_can

      def cannot *preds, obj: nil, saved: true
        not_defined_items = [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          if saved
            next if stored_permissions_rmv(pred: pred, **deconstruct_obj(obj))
            not_defined_items << pms_name
          else
            next not_defined_items << pms_name unless pms_name.in?(defined_permissions.keys)
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
