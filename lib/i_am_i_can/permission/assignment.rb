require 'i_am_i_can/permission/helpers'

module IAmICan
  module Permission
    module Assignment
      include Helpers::Ins

      # permission assignment for stored role
      def can *preds, obj: nil, strict_mode: false, auto_define_before: false
        self.class.have_permissions *preds, obj: obj if auto_define_before || config.auto_define_before
        not_defined_items, covered_items = [ ], [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          covered_items << pms_name if pms_matched?(pms_name, in: stored_permission_names)
          not_defined_items << pms_name unless stored_permissions_add(pred: pred, **deconstruct_obj(obj))
        end

        _pms_assignment_result(preds, obj, not_defined_items, covered_items, strict_mode)
      end

      alias has_permission can

      def temporarily_can *preds, obj: nil, strict_mode: false, auto_define_before: false
        raise Error, 'Permission Assignment: local role was not defined' unless config.subject_model.defined_local_roles.key?(self.name.to_sym)
        self.class.have_permissions *preds, obj: obj, save: false if auto_define_before || config.auto_define_before
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

      def local_permissions
        @local_permissions ||= [ ]
      end

      alias local_permission_names local_permissions

      def stored_permission_names
        stored_permissions.map(&:name)
      end

      # TODO: show by hash
      def permissions
        local_permission_names + stored_permission_names
      end
    end
  end
end
