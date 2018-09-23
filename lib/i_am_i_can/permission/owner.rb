require 'i_am_i_can/permission/helpers'
require 'i_am_i_can/permission/p_array'

module IAmICan
  module Permission
    module Owner
      include Helpers::Cls

      def which(name:)
        find_by!(name: name)
      end

      def have_permission *preds, obj: nil, desc: nil, save: true
        failed_items = [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          description = desc || pms_name.to_s.tr('_', ' ')
          if save
            failed_items << pms_name unless _to_store_permission(pred, obj, desc: description)
          else
            failed_items << pms_name if pms_name.in?(local_permissions.keys)
            local_permissions[pms_name] ||= { desc: description }
          end
        end

        _pms_definition_result(preds, obj, failed_items)
      end

      alias have_permissions have_permission
      alias has_permission   have_permission
      alias has_permissions  have_permission

      def declare_permission *preds, **options
        has_permission *preds, **options, save: false
      end

      alias declare_permissions declare_permission

      def local_permissions
        @local_permissions ||= { }
      end

      def stored_permission_names
        config.permission_model.all.map(&:name)
      end

      def stored_permissions
        config.permission_model.all.map { |pms| [ pms.name, pms.desc ] }.to_h
      end

      def permissions
        local_permissions.deep_merge(stored_permissions)
      end

      def self.extended(kls)
        kls.include InstanceMethods
        kls.delegate :pms_naming, :deconstruct_obj, :pms_of_model_local_role, to: kls
        kls.delegate :permissions, to: kls, prefix: :model
      end
    end

    # === End of ClassMethods ===

    module Owner::InstanceMethods
      include Helpers::Ins

      # permission assignment for stored role
      def can *preds, obj: nil, strict_mode: false, auto_define_before: false
        self.class.have_permissions *preds, obj: obj if auto_define_before || config.auto_define_before
        not_defined_items, covered_items = [ ], [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          covered_items << pms_name if PArray.new(stored_permission_names).matched?(pms_name)
          not_defined_items << pms_name unless stored_permissions_add(pred: pred, **deconstruct_obj(obj))
        end

        _pms_assignment_result(preds, obj, not_defined_items, covered_items, strict_mode)
      end

      alias has_permission can

      def temporarily_can *preds, obj: nil, strict_mode: false, auto_define_before: false
        raise Error, 'Permission Assignment: local role was not defined' unless config.model.local_roles.key?(self.name.to_sym)
        self.class.have_permissions *preds, obj: obj, save: false if auto_define_before || config.auto_define_before
        not_defined_items, covered_items = [ ], [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          next not_defined_items << pms_name unless pms_name.in?(model_permissions.keys)
          covered_items << pms_name if PArray.new(pms_of_model_local_role(self.name)).matched?(pms_name)
          pms_of_model_local_role(self.name) << pms_name
        end

        _pms_assignment_result(preds, obj, not_defined_items, covered_items, strict_mode)
      end

      alias locally_can temporarily_can

      # `can? :manage, User` / `can? :manage, obj: User`
      def can? pred, obj0 = nil, obj: nil
        obj = obj0 || obj
        pms_name = pms_naming(pred, obj)
        temporarily_can?(pred, obj) || PArray.new(stored_permission_names).matched?(pms_name)
      end

      def temporarily_can? pred, obj
        pms_name = pms_naming(pred, obj)
        PArray.new(pms_of_model_local_role(self.name)).matched?(pms_name)
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
