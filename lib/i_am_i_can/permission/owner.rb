require 'i_am_i_can/permission/p_array'

module IAmICan
  module Permission
    module Owner
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

        raise Error, "Done, but #{failed_items} have been defined" if failed_items.present?
        preds
      end

      alias have_permissions have_permission
      alias has_permission   have_permission
      alias has_permissions  have_permission

      def declare_permission *preds, **options
        has_permission *preds, **options, save: false
      end

      alias declare_permissions declare_permission

      def _to_store_permission(pred, obj, **options)
        return false if config.permission_model.exists?(pred, obj)
        config.permission_model.create!(pred: pred, **deconstruct_obj(obj), **options)
      end

      def pms_naming(pred, obj)
        obj_type, obj_id = deconstruct_obj(obj).values
        otp = "_#{obj_type}" if obj_type.present?
        oid = "_#{obj_id}" if obj_id.present?
        [pred, otp, oid].join.to_sym
      end

      def deconstruct_obj(obj)
        config.permission_model.deconstruct_obj(obj)
      end

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
        local_permissions.merge(stored_permissions)
      end

      def self.extended(kls)
        kls.include InstanceMethods
        kls.delegate :pms_naming, :deconstruct_obj, to: kls
        kls.delegate :permissions, to: kls, prefix: :model
      end
    end

    # === End of ClassMethods ===

    module Owner::InstanceMethods
      def can *preds, obj: nil, save: true
        self.class.have_permissions *preds, obj: obj, save: save unless config.use_after_define
        not_defined_items, covered_items = [ ], [ ]

        preds.each do |pred|
          pms_name = pms_naming(pred, obj)
          if save
            covered_items << pms_name if PArray.new(stored_permission_names).matched?(pms_name)
            not_defined_items << pms_name unless stored_permissions_add(pred: pred, **deconstruct_obj(obj))
          else
            next not_defined_items << pms_name unless pms_name.in?(model_permissions.keys)
            covered_items << pms_name if PArray.new(local_permission_names).matched?(pms_name)
            local_permissions << pms_name
          end
        end

        _wrong_assignment_tip(not_defined_items, covered_items)
        preds
      end

      alias has_permission can

      def temporarily_can *preds, **options
        can *preds, save: false, **options
      end

      alias locally_can temporarily_can

      def _wrong_assignment_tip(not_defined_items, covered_items)
        msg1 = "#{not_defined_items} have not been defined" if not_defined_items.present?
        msg2 = "#{covered_items} have been covered" if covered_items.present?
        raise Error, 'Done, but ' + [msg1, msg2].compact.join(', ') if msg1 || msg2
      end

      # `can? :manage, User` / `can? :manage, obj: User`
      def can? pred, obj0 = nil, obj: nil
        obj = obj0 || obj
        pms_name = pms_naming(pred, obj)
        temporarily_can?(pred, obj) || PArray.new(stored_permission_names).matched?(pms_name)
      end

      def temporarily_can? pred, obj
        pms_name = pms_naming(pred, obj)
        PArray.new(local_permission_names).matched?(pms_name)
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
